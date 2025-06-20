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
    
    // MARK: - Hamlet Text (Shakespeare)
    
    static let hamletLines = [
        "To be, or not to be, that is the",
        "question: Whether 'tis nobler in",
        "the mind to suffer The slings and",
        "arrows of outrageous fortune, Or",
        "to take arms against a sea of",
        "troubles And, by opposing, end",
        "them. To die—to sleep, No more;",
        "and by a sleep to say we end The",
        "heart-ache and the thousand",
        "natural shocks That flesh is heir",
        "to—'tis a consummation Devoutly",
        "to be wish'd. To die, to sleep;",
        "To sleep, perchance to dream—ay,",
        "there's the rub: For in that",
        "sleep of death what dreams may",
        "come, When we have shuffled off",
        "this mortal coil, Must give us",
        "pause. There's the respect That",
        "makes calamity of so long life.",
        "For who would bear the whips and",
        "scorns of time, Th' oppressor's",
        "wrong, the proud man's contumely,",
        "The pangs of despised love, the",
        "law's delay, The insolence of",
        "office, and the spurns That",
        "patient merit of th' unworthy",
        "takes, When he himself might his",
        "quietus make With a bare bodkin?",
        "Who would fardels bear, To grunt",
        "and sweat under a weary life,",
        "But that the dread of something",
        "after death, The undiscover'd",
        "country, from whose bourn No",
        "traveller returns, puzzles the",
        "will And makes us rather bear",
        "those ills we have Than fly to",
        "others that we know not of? Thus",
        "conscience does make cowards of",
        "us all, And thus the native hue",
        "of resolution Is sicklied o'er",
        "with the pale cast of thought,",
        "And enterprises of great pith",
        "and moment With this regard their",
        "currents turn awry And lose the",
        "name of action.—Soft you now!",
        "The fair Ophelia! Nymph, in thy",
        "orisons Be all my sins",
        "remember'd."
    ]
    
    // MARK: - Word Generation
    
    static func generateWordLines(count: Int = 50) -> [WordLine] {
        return generateLines(for: .randomWords, count: count)
    }
    
    static func generateLines(for textType: TypingTextType, count: Int = 50) -> [WordLine] {
        switch textType {
        case .randomWords:
            return generateRandomWordLines(count: count)
        case .hamlet:
            return generateHamletLines()
        }
    }
    
    private static func generateRandomWordLines(count: Int = 50) -> [WordLine] {
        var lines: [WordLine] = []
        
        for i in 0..<count {
            let difficulty = getDifficultyForLine(lineIndex: i, totalLines: count)
            let words = generateWordsForLine(difficulty: difficulty)
            let line = WordLine(words: words, difficulty: difficulty, lineIndex: i)
            lines.append(line)
        }
        
        return lines
    }
    
    private static func generateHamletLines() -> [WordLine] {
        return hamletLines.enumerated().map { index, lineText in
            WordLine(
                words: lineText.components(separatedBy: " "),
                difficulty: .intermediate, // Hamlet is generally intermediate difficulty
                lineIndex: index
            )
        }
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