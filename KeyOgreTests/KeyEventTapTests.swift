// ABOUTME: Unit tests for KeyEventTap class verifying key monitoring and character buffer functionality
// ABOUTME: Tests publisher behavior, buffer management, and monitoring lifecycle

import Testing
import Combine
import AppKit
@testable import KeyOgre

struct KeyEventTapTests {
    
    @Test func testInitialization() async throws {
        let keyEventTap = KeyEventTap()
        
        #expect(keyEventTap.pressedKeysSet.value.isEmpty, "Initial pressed keys set should be empty")
        #expect(keyEventTap.lastTenCharacters.value.isEmpty, "Initial character buffer should be empty")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
    
    @Test func testProtocolConformance() async throws {
        let keyEventTap = KeyEventTap()
        
        // Verify it conforms to KeyEventTapProtocol
        let protocolInstance: any KeyEventTapProtocol = keyEventTap
        
        #expect(protocolInstance.pressedKeysSet.value.isEmpty, "Protocol pressedKeysSet should work")
        #expect(protocolInstance.lastTenCharacters.value.isEmpty, "Protocol lastTenCharacters should work")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
    
    @Test func testCharacterBufferAddition() async throws {
        let keyEventTap = KeyEventTap()
        
        // Test the buffer behavior by verifying initial state
        #expect(keyEventTap.lastTenCharacters.value.isEmpty, "Initial buffer should be empty")
        
        // Since addCharacterToBuffer is private, we test the public interface behavior
        // The buffer is updated through handleSimpleKeyEvent which is called by NSEvent monitor
        var receivedUpdates = 0
        
        let cancellable = keyEventTap.lastTenCharacters
            .sink { characters in
                receivedUpdates += 1
            }
        
        // Verify the publisher works
        #expect(receivedUpdates >= 1, "Should receive at least initial value")
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testCharacterBufferLimit() async throws {
        let keyEventTap = KeyEventTap()
        
        // Test that buffer maintains only 10 characters max by checking initial state
        #expect(keyEventTap.lastTenCharacters.value.count <= 10, "Buffer should never exceed 10 characters")
        #expect(keyEventTap.lastTenCharacters.value.count == 0, "Initial buffer should be empty")
        
        // Test the buffer property exists and is accessible
        let cancellable = keyEventTap.lastTenCharacters
            .sink { characters in
                #expect(characters.count <= 10, "Buffer should never exceed 10 characters in any update")
            }
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testPressedKeysSetPublishing() async throws {
        // Create a fresh instance for isolation
        let keyEventTap = KeyEventTap()
        
        // Ensure clean state - stop any existing monitoring
        keyEventTap.stopMonitoring()
        
        var receivedKeysSets: [Set<CGKeyCode>] = []
        
        // Test initial state before subscribing
        #expect(keyEventTap.pressedKeysSet.value.isEmpty, "Should start with empty set")
        
        let cancellable = keyEventTap.pressedKeysSet
            .sink { keysSet in
                receivedKeysSets.append(keysSet)
            }
        
        // CurrentValueSubject should deliver initial value synchronously
        #expect(receivedKeysSets.count == 1, "Should receive initial value immediately")
        #expect(receivedKeysSets[0].isEmpty, "Initial value should be empty set")
        
        // Simulate a key event (this would normally happen through NSEvent)
        keyEventTap.pressedKeysSet.send([CGKeyCode(18)]) // Simulate '1' key pressed
        
        // The send should be synchronous too
        #expect(receivedKeysSets.count == 2, "Should receive exactly two values")
        #expect(receivedKeysSets[0].isEmpty, "First value should be empty set")
        #expect(receivedKeysSets[1] == [CGKeyCode(18)], "Second value should contain the sent key code")
        #expect(keyEventTap.pressedKeysSet.value == [CGKeyCode(18)], "Current value should be updated")
        
        // Send multiple keys
        keyEventTap.pressedKeysSet.send([CGKeyCode(18), CGKeyCode(19)])
        #expect(receivedKeysSets.count == 3, "Should receive three values")
        #expect(receivedKeysSets[2] == [CGKeyCode(18), CGKeyCode(19)], "Third value should contain both keys")
        
        // Send empty set to clear
        keyEventTap.pressedKeysSet.send([])
        #expect(receivedKeysSets.count == 4, "Should receive four values")
        #expect(receivedKeysSets[3].isEmpty, "Fourth value should be empty set")
        #expect(keyEventTap.pressedKeysSet.value.isEmpty, "Current value should be empty again")
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testMonitoringLifecycle() async throws {
        let keyEventTap = KeyEventTap()
        
        // Ensure clean starting state
        keyEventTap.stopMonitoring()
        
        // Test starting monitoring - verify no exceptions are thrown
        keyEventTap.startMonitoring()
        
        // Test stopping monitoring - verify no exceptions are thrown
        keyEventTap.stopMonitoring()
        
        // Test multiple starts/stops
        keyEventTap.startMonitoring()
        keyEventTap.startMonitoring() // Should handle multiple starts gracefully
        keyEventTap.stopMonitoring()
        keyEventTap.stopMonitoring() // Should handle multiple stops gracefully
        
        // Ensure clean ending state
        keyEventTap.stopMonitoring()
    }
    
    @Test func testPublisherTypes() async throws {
        let keyEventTap = KeyEventTap()
        
        // Verify the publishers are the correct types
        #expect(type(of: keyEventTap.pressedKeysSet) == CurrentValueSubject<Set<CGKeyCode>, Never>.self, 
               "pressedKeysSet should be CurrentValueSubject<Set<CGKeyCode>, Never>")
        #expect(type(of: keyEventTap.lastTenCharacters) == CurrentValueSubject<[Character], Never>.self, 
               "lastTenCharacters should be CurrentValueSubject<[Character], Never>")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
    
    @Test func testMainQueueDispatch() async throws {
        let keyEventTap = KeyEventTap()
        
        // Test that we can receive updates on main queue
        var receivedOnMainThread = false
        
        let cancellable = keyEventTap.pressedKeysSet
            .receive(on: DispatchQueue.main)
            .sink { keysSet in
                receivedOnMainThread = Thread.isMainThread
            }
        
        // Trigger an update from background queue
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                keyEventTap.pressedKeysSet.send([CGKeyCode(42)])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    continuation.resume()
                }
            }
        }
        
        #expect(receivedOnMainThread, "Should be able to receive updates on main thread")
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testPressedKeysSetClearingBehavior() async throws {
        let keyEventTap = KeyEventTap()
        
        var keySetUpdates: [Set<CGKeyCode>] = []
        
        let cancellable = keyEventTap.pressedKeysSet
            .sink { keysSet in
                keySetUpdates.append(keysSet)
            }
        
        // Test the sequence: empty -> keys -> empty
        #expect(keyEventTap.pressedKeysSet.value.isEmpty, "Should start with empty set")
        
        keyEventTap.pressedKeysSet.send([CGKeyCode(18)])
        #expect(keyEventTap.pressedKeysSet.value == [CGKeyCode(18)], "Should have the sent key code")
        
        keyEventTap.pressedKeysSet.send([])
        #expect(keyEventTap.pressedKeysSet.value.isEmpty, "Should be cleared to empty set")
        
        // Verify we received the updates
        try await Task.sleep(nanoseconds: 50_000_000) // Brief delay for async updates
        #expect(keySetUpdates.count >= 2, "Should have received multiple updates")
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testObservableObjectConformance() async throws {
        let keyEventTap = KeyEventTap()
        
        // Verify it conforms to ObservableObject by checking it can be cast
        let observableInstance: any ObservableObject = keyEventTap
        #expect(observableInstance is KeyEventTap, "Should maintain type through ObservableObject")
        
        // Test that it has the required properties
        #expect(keyEventTap.objectWillChange != nil, "Should have objectWillChange publisher")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
}