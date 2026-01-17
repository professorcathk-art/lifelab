import Foundation

struct ReflectionQuestion {
    let id: Int
    let question: String
    let purpose: String
    let exampleAnswer: String
}

struct ReflectionQuestions {
    static let shared = ReflectionQuestions()
    
    let questions: [ReflectionQuestion] = [
        ReflectionQuestion(
            id: 1,
            question: "假設你已經擁有足夠的財富，不再需要為金錢工作，那麼你最想把時間投入在什麼事情上？為什麼這件事對你如此重要？",
            purpose: "識別超越物質需求的內在動機",
            exampleAnswer: "我想投入時間教導年輕人如何建立自信和發掘潛能，因為我深信每個人都有獨特的價值，只是需要被啟發和引導。看到他們的成長和蛻變，讓我感到生命有了深刻的意義。"
        ),
        ReflectionQuestion(
            id: 2,
            question: "回想你人生中最有成就感的時刻，當時你為誰創造了什麼價值？這個經驗讓你體會到什麼？",
            purpose: "從過往經驗中識別價值創造模式",
            exampleAnswer: "最有成就感的是幫助一位憂鬱的朋友重新找到生活希望。透過長時間的陪伴和傾聽，我為她提供了情感支持和不同的思考角度。這讓我體會到，有時候一個人的關愛和理解，就能成為別人生命中的光。"
        ),
        ReflectionQuestion(
            id: 3,
            question: "如果你只能選擇一種方式為這個世界留下痕跡，你希望後人記住你什麼？你想透過什麼行動實現這個願望？",
            purpose: "探索深層的人生意義和遺產",
            exampleAnswer: "我希望被記住為一個激發他人勇氣的人。透過分享真實的生命故事和內心的掙扎，我想讓更多人明白，每個人都可以超越困境，活出更勇敢的自己。"
        ),
        ReflectionQuestion(
            id: 4,
            question: "想像在你的告別式上，你最希望聽到別人如何描述你對他們生命的影響？你現在需要採取什麼行動來實現這個影響？",
            purpose: "以終為始，明確人生遺產",
            exampleAnswer: "我希望聽到：『她總是相信我們的潛能，即使我們自己都不相信的時候。她的鼓勵和指導改變了我們的人生軌跡。』為了實現這個影響，我需要更積極地參與教育和輔導工作。"
        ),
        ReflectionQuestion(
            id: 5,
            question: "如果你有超能力可以解決世界上的一個問題，你會選擇解決什麼？為什麼這個問題對你來說如此重要？",
            purpose: "識別內心最深層的關懷",
            exampleAnswer: "我會選擇解決人們內心的孤獨和自我價值感缺失。因為我相信很多社會問題的根源都來自於人們不了解自己的價值，不知道如何與他人建立真誠的連結。如果每個人都能感受到被愛和被需要，世界會變得更美好。"
        ),
        ReflectionQuestion(
            id: 6,
            question: "在你的人際關係中，你最享受扮演什麼角色？透過這個角色，你為他人提供了什麼獨特的價值？",
            purpose: "發現個人獨特的貢獻方式",
            exampleAnswer: "我最享受扮演啟發者和引導者的角色。透過提出深度的問題和分享不同的觀點，我幫助朋友們更深入地思考自己的選擇和人生方向，讓他們找到屬於自己的答案。"
        ),
        ReflectionQuestion(
            id: 7,
            question: "什麼樣的痛苦或困難最能觸動你的心，讓你想要採取行動去幫助？你認為自己有什麼獨特的能力可以在這個領域創造價值？",
            purpose: "探索個人的使命感和天賦",
            exampleAnswer: "看到年輕人因為缺乏自信而限制自己的可能性，最讓我心痛。我有很強的洞察力和溝通能力，擅長發現他人的潛能並用合適的方式表達出來，這讓我能夠有效地幫助他們建立自信。"
        )
    ]
}
