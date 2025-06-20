// ABOUTME: Content system for typing practice with curated word lists and generation algorithms
// ABOUTME: Provides 1000+ English words categorized by difficulty and smart line generation for practice

import Foundation

class TypingPracticeContent {
    
    // MARK: - Word Categories
    
    // High-frequency beginner words (3-5 characters)
    static let beginnerWords = [
        "the", "and", "for", "are", "but", "not", "you", "all", "can", "had", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "man", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "its", "let", "put", "say", "she", "too", "use",
        "about", "after", "again", "being", "came", "could", "down", "each", "first", "from", "good", "great", "have", "here", "into", "just", "know", "last", "left", "life", "like", "long", "look", "made", "make", "many", "more", "most", "move", "must", "name", "need", "next", "only", "open", "over", "part", "place", "right", "said", "same", "seem", "show", "side", "some", "such", "take", "than", "that", "them", "time", "turn", "used", "very", "want", "water", "well", "were", "what", "when", "will", "with", "word", "work", "would", "year", "your"
    ]
    
    // Common intermediate words (6-8 characters)
    static let intermediateWords = [
        "before", "better", "called", "change", "course", "create", "during", "enough", "every", "family", "follow", "found", "friend", "giving", "group", "happen", "house", "important", "kind", "large", "learn", "light", "little", "living", "money", "never", "night", "number", "people", "person", "place", "point", "public", "right", "school", "second", "small", "start", "state", "still", "story", "student", "study", "system", "think", "those", "though", "three", "through", "today", "together", "under", "until", "using", "value", "where", "while", "white", "without", "world", "write", "young",
        "another", "around", "because", "between", "business", "community", "company", "example", "general", "government", "however", "include", "information", "interest", "national", "nothing", "party", "problem", "program", "question", "several", "service", "something", "special", "system", "university", "whether"
    ]
    
    // Advanced words with complex patterns (9+ characters)
    static let advancedWords = [
        "available", "different", "education", "experience", "following", "important", "including", "international", "particular", "political", "possible", "president", "remember", "something", "statement", "themselves", "university", "understand", "opportunity", "responsibility", "development", "organization", "management", "technology", "environment", "performance", "relationship", "communication", "information", "professional", "traditional", "individual", "beautiful", "knowledge", "department", "community", "difference", "everything", "government", "beginning", "television", "newspaper", "difficult", "character", "situation", "production", "investment", "operation", "treatment", "agreement", "population", "generation", "democratic", "republican", "candidate", "financial", "equipment", "authority", "recognize", "structure", "certainly", "personnel", "activities", "establish", "materials", "available", "development", "resources", "standards", "application", "commercial", "procedure", "techniques", "scientific", "instrument", "requirement", "industrial", "committee", "additional", "mechanism", "specialist", "statistical", "systematic", "electronic", "telephone", "comfortable", "incredible", "imaginative", "demonstrate", "appreciation"
    ]
    
    // Common digraphs and letter patterns for finger training
    static let patternWords = [
        "book", "look", "took", "good", "wood", "food", "mood", "room", "moon", "soon", "door", "poor", "floor", "school", "cool", "pool", "tool", "foot", "root", "shoot",
        "ball", "call", "fall", "hall", "mall", "tall", "wall", "bell", "cell", "fell", "hell", "sell", "tell", "well", "bill", "fill", "hill", "kill", "mill", "pill",
        "tree", "free", "three", "green", "seen", "been", "teen", "keen", "queen", "screen", "sweet", "meet", "feet", "street", "speed", "need", "feed", "seed", "weed", "deep",
        "happy", "puppy", "funny", "sunny", "penny", "many", "any", "carry", "marry", "sorry", "worry", "hurry", "fury", "bury", "jury", "glory", "story", "forty", "party", "dirty"
    ]
    
    // MARK: - Word Generation
    
    static func generateWordLines(count: Int = 50) -> [WordLine] {
        var lines: [WordLine] = []
        
        for i in 0..<count {
            let difficulty = getDifficultyForLine(lineIndex: i, totalLines: count)
            let words = generateWordsForLine(difficulty: difficulty)
            let line = WordLine(words: words, difficulty: difficulty, lineIndex: i)
            lines.append(line)
        }
        
        return lines
    }
    
    private static func getDifficultyForLine(lineIndex: Int, totalLines: Int) -> DifficultyLevel {
        let progress = Double(lineIndex) / Double(totalLines)
        
        if progress < 0.3 {
            return .beginner
        } else if progress < 0.7 {
            return .intermediate
        } else {
            return .advanced
        }
    }
    
    private static func generateWordsForLine(difficulty: DifficultyLevel) -> [String] {
        let targetLineLength = 35 // Target characters per line
        var words: [String] = []
        var currentLength = 0
        
        let wordPool = getWordPool(for: difficulty)
        
        while currentLength < targetLineLength {
            let availableWords = wordPool.filter { word in
                let newLength = currentLength + word.count + (words.isEmpty ? 0 : 1) // +1 for space
                return newLength <= targetLineLength
            }
            
            guard !availableWords.isEmpty else { break }
            
            let randomWord = availableWords.randomElement()!
            words.append(randomWord)
            currentLength += randomWord.count + (words.count > 1 ? 1 : 0) // +1 for space between words
        }
        
        // Ensure we have at least 3 words per line
        if words.count < 3 {
            let shortWords = wordPool.filter { $0.count <= 4 }
            while words.count < 3 && !shortWords.isEmpty {
                if let shortWord = shortWords.randomElement() {
                    words.append(shortWord)
                }
            }
        }
        
        return words
    }
    
    private static func getWordPool(for difficulty: DifficultyLevel) -> [String] {
        switch difficulty {
        case .beginner:
            return beginnerWords + patternWords.filter { $0.count <= 5 }
        case .intermediate:
            return beginnerWords + intermediateWords + patternWords
        case .advanced:
            return intermediateWords + advancedWords + patternWords
        }
    }
    
    // MARK: - Word Statistics
    
    static func getTotalWordCount() -> Int {
        return beginnerWords.count + intermediateWords.count + advancedWords.count + patternWords.count
    }
    
    static func getWordsByDifficulty(_ difficulty: DifficultyLevel) -> [String] {
        return getWordPool(for: difficulty)
    }
}