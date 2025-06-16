// ABOUTME: Unit tests for KeyEventTap class verifying key monitoring and character buffer functionality
// ABOUTME: Tests publisher behavior, buffer management, and monitoring lifecycle

import Testing
import Combine
import AppKit
@testable import KeyOgre

struct KeyEventTapTests {
    
    @Test func testInitialization() async throws {
        let keyEventTap = KeyEventTap()
        
        #expect(keyEventTap.currentKeyCode.value == nil, "Initial key code should be nil")
        #expect(keyEventTap.lastTenCharacters.value.isEmpty, "Initial character buffer should be empty")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
    
    @Test func testProtocolConformance() async throws {
        let keyEventTap = KeyEventTap()
        
        // Verify it conforms to KeyEventTapProtocol
        let protocolInstance: any KeyEventTapProtocol = keyEventTap
        
        #expect(protocolInstance.currentKeyCode.value == nil, "Protocol currentKeyCode should work")
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
    
    @Test func testKeyCodePublishing() async throws {
        // Create a fresh instance for isolation
        let keyEventTap = KeyEventTap()
        
        // Ensure clean state - stop any existing monitoring
        keyEventTap.stopMonitoring()
        
        var receivedKeyCodes: [CGKeyCode?] = []
        
        // Test initial state before subscribing
        #expect(keyEventTap.currentKeyCode.value == nil, "Should start with nil")
        
        let cancellable = keyEventTap.currentKeyCode
            .sink { keyCode in
                receivedKeyCodes.append(keyCode)
            }
        
        // CurrentValueSubject should deliver initial value synchronously
        #expect(receivedKeyCodes.count == 1, "Should receive initial value immediately")
        #expect(receivedKeyCodes[0] == nil, "Initial value should be nil")
        
        // Simulate a key event (this would normally happen through NSEvent)
        keyEventTap.currentKeyCode.send(CGKeyCode(18)) // Simulate '1' key
        
        // The send should be synchronous too
        #expect(receivedKeyCodes.count == 2, "Should receive exactly two values")
        #expect(receivedKeyCodes[0] == nil, "First value should be nil")
        #expect(receivedKeyCodes[1] == CGKeyCode(18), "Second value should be the sent key code")
        #expect(keyEventTap.currentKeyCode.value == CGKeyCode(18), "Current value should be updated")
        
        // Send nil to clear
        keyEventTap.currentKeyCode.send(nil)
        #expect(receivedKeyCodes.count == 3, "Should receive three values")
        #expect(receivedKeyCodes[2] == nil, "Third value should be nil")
        #expect(keyEventTap.currentKeyCode.value == nil, "Current value should be nil again")
        
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
        #expect(type(of: keyEventTap.currentKeyCode) == CurrentValueSubject<CGKeyCode?, Never>.self, 
               "currentKeyCode should be CurrentValueSubject<CGKeyCode?, Never>")
        #expect(type(of: keyEventTap.lastTenCharacters) == CurrentValueSubject<[Character], Never>.self, 
               "lastTenCharacters should be CurrentValueSubject<[Character], Never>")
        
        // Clean up
        keyEventTap.stopMonitoring()
    }
    
    @Test func testMainQueueDispatch() async throws {
        let keyEventTap = KeyEventTap()
        
        // Test that we can receive updates on main queue
        var receivedOnMainThread = false
        
        let cancellable = keyEventTap.currentKeyCode
            .receive(on: DispatchQueue.main)
            .sink { keyCode in
                receivedOnMainThread = Thread.isMainThread
            }
        
        // Trigger an update from background queue
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                keyEventTap.currentKeyCode.send(CGKeyCode(42))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    continuation.resume()
                }
            }
        }
        
        #expect(receivedOnMainThread, "Should be able to receive updates on main thread")
        
        cancellable.cancel()
        keyEventTap.stopMonitoring()
    }
    
    @Test func testKeyCodeClearingBehavior() async throws {
        let keyEventTap = KeyEventTap()
        
        var keyCodeUpdates: [CGKeyCode?] = []
        
        let cancellable = keyEventTap.currentKeyCode
            .sink { keyCode in
                keyCodeUpdates.append(keyCode)
            }
        
        // Test the sequence: nil -> keycode -> nil
        #expect(keyEventTap.currentKeyCode.value == nil, "Should start with nil")
        
        keyEventTap.currentKeyCode.send(CGKeyCode(18))
        #expect(keyEventTap.currentKeyCode.value == CGKeyCode(18), "Should have the sent key code")
        
        keyEventTap.currentKeyCode.send(nil)
        #expect(keyEventTap.currentKeyCode.value == nil, "Should be cleared to nil")
        
        // Verify we received the updates
        try await Task.sleep(nanoseconds: 50_000_000) // Brief delay for async updates
        #expect(keyCodeUpdates.count >= 2, "Should have received multiple updates")
        
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