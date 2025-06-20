# Plan: Add Dropdown and Restart Button to Typing Practice

## Overview
Add a control bar similar to coding practice, but for typing practice with text selection options instead of programming languages. Refactor LanguageControlBar into a generic reusable component.

## Implementation Steps

### 1. Create Text Content Enum
- Add a new enum `TypingTextType` in `TypingPracticeModels.swift` with:
  - `randomWords` (current default)
  - `hamlet` (new Shakespeare option)
- Add corresponding icons and display names

### 2. Add Hamlet Text Content
- Extend `TypingPracticeContent.swift` to support different text types
- Break down Hamlet text into lines <35 characters:

```
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
```

### 3. Create Generic PracticeControlBar Component
- Refactor `LanguageControlBar.swift` into `PracticeControlBar.swift`
- Make it generic with protocol-based approach:
  ```swift
  protocol PracticeControlOption {
      var displayName: String { get }
      var icon: String { get }
  }
  
  struct PracticeControlBar<T: PracticeControlOption & Hashable>: View {
      @Binding var selectedOption: T
      let options: [T]
      let onRestart: () -> Void
      let title: String
  }
  ```

### 4. Update Existing Components
- Make `ProgrammingLanguage` conform to `PracticeControlOption`
- Make `TypingTextType` conform to `PracticeControlOption`
- Update `LanguageControlBar` to use the new generic component
- Create `TypingControlBar` using the same generic component

### 5. Update TypingPracticeManager
- Add `currentTextType` property to state
- Add `switchTextType()` method
- Modify `generateWordLines()` to use selected text type
- Add `restartCurrentText()` method

### 6. Update TypingPracticeState
- Add `currentTextType: TypingTextType = .randomWords`
- Ensure state management handles text type switching

### 7. Update MainContentView
- Add typing control bar above typing practice view (similar to language controls for coding)
- Use the generic component for both coding and typing practice
- Conditionally show appropriate controls based on mode

### 8. Preserve Existing Functionality
- Keep "Random words" as default option
- Ensure coding practice dropdown remains unchanged
- Maintain all existing typing practice features

## Files to Modify
1. `KeyOgre/Models/TypingPracticeModels.swift` - Add text type enum
2. `KeyOgre/Managers/TypingPracticeContent.swift` - Add Hamlet content and text type support
3. `KeyOgre/Managers/TypingPracticeManager.swift` - Add text type switching
4. `KeyOgre/Views/Components/LanguageControlBar.swift` - Refactor to generic PracticeControlBar
5. `KeyOgre/Models/CodingPracticeModels.swift` - Make ProgrammingLanguage conform to protocol
6. `KeyOgre/Views/MainContentView.swift` - Add typing control bar UI