import Foundation

// MARK: - Data Models for Question 1 (Bottom Sheet Pattern)
struct SubTalent: Identifiable, Hashable {
    let id: String
    let label: String
}

struct TalentCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subTalents: [SubTalent]
}

// MARK: - Data Models for Question 2 (Bottom Sheet Pattern - Energy/Vitality)
struct SubEnergy: Identifiable, Hashable {
    let id: String
    let label: String
}

struct EnergyCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subEnergies: [SubEnergy]
}

// MARK: - Data Models for Question 3 (Bottom Sheet Pattern - Praise/Recognition)
struct SubPraise: Identifiable, Hashable {
    let id: String
    let label: String
}

struct PraiseCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subPraises: [SubPraise]
}

// MARK: - Data Models for Question 4 (Bottom Sheet Pattern - Fast Learning)
struct SubLearning: Identifiable, Hashable {
    let id: String
    let label: String
}

struct LearningCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subLearning: [SubLearning]
}

// MARK: - Data Models for Question 5 (Bottom Sheet Pattern - Fulfillment/Meaning)
struct SubFulfillment: Identifiable, Hashable {
    let id: String
    let label: String
}

struct FulfillmentCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subFulfillment: [SubFulfillment]
}

struct StrengthsQuestion {
    let id: Int
    let question: String
    let exampleAnswer: String
    let hints: [String]
    let suggestedKeywords: [String]
    let keywordHierarchy: [String: [String]] // First-level keyword -> related keywords (for Questions 4-5)
    // New: For Question 1 only - Bottom Sheet pattern
    let talentCategories: [TalentCategory]? // Only Question 1 uses this
    // New: For Question 2 only - Bottom Sheet pattern (Energy/Vitality)
    let energyCategories: [EnergyCategory]? // Only Question 2 uses this
    // New: For Question 3 only - Bottom Sheet pattern (Praise/Recognition)
    let praiseCategories: [PraiseCategory]? // Only Question 3 uses this
    // New: For Question 4 only - Bottom Sheet pattern (Fast Learning)
    let learningCategories: [LearningCategory]? // Only Question 4 uses this
    // New: For Question 5 only - Bottom Sheet pattern (Fulfillment/Meaning)
    let fulfillmentCategories: [FulfillmentCategory]? // Only Question 5 uses this
}

struct StrengthsQuestions {
    static let shared = StrengthsQuestions()
    
    let questions: [StrengthsQuestion] = [
        StrengthsQuestion(
            id: 1,
            question: "哪些事情對你來說是「輕而易舉」的？",
            exampleAnswer: "我能快速理解複雜的數據關係，看到電子表格就能直覺地找出問題所在；朋友聚會時我總是能輕鬆調節氣氛，讓每個人都感到舒適；寫作對我來說很自然，別人需要苦思的文字我能快速組織出來",
            hints: [
                "回想童年時期就展現的能力",
                "想想同事或朋友經常向你求助的事情",
                "考慮你在工作或學習中「不費力」就能完成的任務",
                "注意那些你做起來很順手，但看到別人做卻覺得他們很辛苦的事情"
            ],
            suggestedKeywords: [], // Not used for Question 1 (uses talentCategories instead)
            keywordHierarchy: [:], // Not used for Question 1 (uses talentCategories instead)
            talentCategories: [
                TalentCategory(
                    id: "analytical",
                    title: "分析與運算",
                    subTalents: [
                        SubTalent(id: "an1", label: "發現規律"),
                        SubTalent(id: "an2", label: "數字直覺"),
                        SubTalent(id: "an3", label: "拆解問題"),
                        SubTalent(id: "an4", label: "預測趨勢"),
                        SubTalent(id: "an5", label: "抓出錯誤"),
                        SubTalent(id: "an6", label: "圖表解讀"),
                        SubTalent(id: "an7", label: "成本概念"),
                        SubTalent(id: "an8", label: "邏輯推演")
                    ]
                ),
                TalentCategory(
                    id: "interpersonal",
                    title: "人際與共情",
                    subTalents: [
                        SubTalent(id: "in1", label: "察言觀色"),
                        SubTalent(id: "in2", label: "安撫情緒"),
                        SubTalent(id: "in3", label: "快速破冰"),
                        SubTalent(id: "in4", label: "傾聽心聲"),
                        SubTalent(id: "in5", label: "建立信任"),
                        SubTalent(id: "in6", label: "感受氛圍"),
                        SubTalent(id: "in7", label: "化解尷尬"),
                        SubTalent(id: "in8", label: "記住細節")
                    ]
                ),
                TalentCategory(
                    id: "writing",
                    title: "文字與語感",
                    subTalents: [
                        SubTalent(id: "wr1", label: "構思故事"),
                        SubTalent(id: "wr2", label: "精準用詞"),
                        SubTalent(id: "wr3", label: "抓出錯字"),
                        SubTalent(id: "wr4", label: "濃縮重點"),
                        SubTalent(id: "wr5", label: "情感表達"),
                        SubTalent(id: "wr6", label: "快速產出"),
                        SubTalent(id: "wr7", label: "模仿語氣"),
                        SubTalent(id: "wr8", label: "結構佈局")
                    ]
                ),
                TalentCategory(
                    id: "logical",
                    title: "邏輯與思辨",
                    subTalents: [
                        SubTalent(id: "lo1", label: "抓到破綻"),
                        SubTalent(id: "lo2", label: "因果推導"),
                        SubTalent(id: "lo3", label: "系統思考"),
                        SubTalent(id: "lo4", label: "權衡利弊"),
                        SubTalent(id: "lo5", label: "制定策略"),
                        SubTalent(id: "lo6", label: "快速歸納"),
                        SubTalent(id: "lo7", label: "抽象理解"),
                        SubTalent(id: "lo8", label: "危機預判")
                    ]
                ),
                TalentCategory(
                    id: "creativity",
                    title: "靈感與創意",
                    subTalents: [
                        SubTalent(id: "cr1", label: "點子無限"),
                        SubTalent(id: "cr2", label: "換位思考"),
                        SubTalent(id: "cr3", label: "舉一反三"),
                        SubTalent(id: "cr4", label: "聯想能力"),
                        SubTalent(id: "cr5", label: "突破框架"),
                        SubTalent(id: "cr6", label: "視覺想像"),
                        SubTalent(id: "cr7", label: "隨機應變"),
                        SubTalent(id: "cr8", label: "組合新意")
                    ]
                ),
                TalentCategory(
                    id: "organization",
                    title: "規劃與秩序",
                    subTalents: [
                        SubTalent(id: "or1", label: "安排排程"),
                        SubTalent(id: "or2", label: "物品歸類"),
                        SubTalent(id: "or3", label: "抓準時間"),
                        SubTalent(id: "or4", label: "制定步驟"),
                        SubTalent(id: "or5", label: "分配資源"),
                        SubTalent(id: "or6", label: "按部就班"),
                        SubTalent(id: "or7", label: "預先準備"),
                        SubTalent(id: "or8", label: "清單控管")
                    ]
                ),
                TalentCategory(
                    id: "technical",
                    title: "系統與技術",
                    subTalents: [
                        SubTalent(id: "te1", label: "摸透軟體"),
                        SubTalent(id: "te2", label: "排除故障"),
                        SubTalent(id: "te3", label: "找出漏洞"),
                        SubTalent(id: "te4", label: "自動化流"),
                        SubTalent(id: "te5", label: "工具應用"),
                        SubTalent(id: "te6", label: "建立模組"),
                        SubTalent(id: "te7", label: "數位學習"),
                        SubTalent(id: "te8", label: "流程優化")
                    ]
                ),
                TalentCategory(
                    id: "visual",
                    title: "視覺與美學",
                    subTalents: [
                        SubTalent(id: "vi1", label: "顏色敏銳"),
                        SubTalent(id: "vi2", label: "空間概念"),
                        SubTalent(id: "vi3", label: "排版直覺"),
                        SubTalent(id: "vi4", label: "美感品味"),
                        SubTalent(id: "vi5", label: "畫面構圖"),
                        SubTalent(id: "vi6", label: "捕捉光影"),
                        SubTalent(id: "vi7", label: "視覺記憶"),
                        SubTalent(id: "vi8", label: "發現不均")
                    ]
                ),
                TalentCategory(
                    id: "musical",
                    title: "聲音與節奏",
                    subTalents: [
                        SubTalent(id: "mu1", label: "音準極佳"),
                        SubTalent(id: "mu2", label: "記住旋律"),
                        SubTalent(id: "mu3", label: "節奏敏銳"),
                        SubTalent(id: "mu4", label: "聽聲辨人"),
                        SubTalent(id: "mu5", label: "模仿聲音"),
                        SubTalent(id: "mu6", label: "感受音場"),
                        SubTalent(id: "mu7", label: "情緒共鳴"),
                        SubTalent(id: "mu8", label: "聽出雜音")
                    ]
                ),
                TalentCategory(
                    id: "physical",
                    title: "肢體與動覺",
                    subTalents: [
                        SubTalent(id: "ph1", label: "肌肉記憶"),
                        SubTalent(id: "ph2", label: "身體協調"),
                        SubTalent(id: "ph3", label: "空間平衡"),
                        SubTalent(id: "ph4", label: "模仿動作"),
                        SubTalent(id: "ph5", label: "精細手工"),
                        SubTalent(id: "ph6", label: "體能耐力"),
                        SubTalent(id: "ph7", label: "反射神經"),
                        SubTalent(id: "ph8", label: "掌控力道")
                    ]
                ),
                TalentCategory(
                    id: "language",
                    title: "語言與天賦",
                    subTalents: [
                        SubTalent(id: "la1", label: "語感直覺"),
                        SubTalent(id: "la2", label: "模仿口音"),
                        SubTalent(id: "la3", label: "單字記憶"),
                        SubTalent(id: "la4", label: "快速切換"),
                        SubTalent(id: "la5", label: "聽懂言外"),
                        SubTalent(id: "la6", label: "大腦翻譯"),
                        SubTalent(id: "la7", label: "掌握俚語"),
                        SubTalent(id: "la8", label: "語法解構")
                    ]
                ),
                TalentCategory(
                    id: "teaching",
                    title: "知識與轉譯",
                    subTalents: [
                        SubTalent(id: "tc1", label: "換句話說"),
                        SubTalent(id: "tc2", label: "舉例說明"),
                        SubTalent(id: "tc3", label: "拆解步驟"),
                        SubTalent(id: "tc4", label: "找出盲點"),
                        SubTalent(id: "tc5", label: "激發興趣"),
                        SubTalent(id: "tc6", label: "耐心解答"),
                        SubTalent(id: "tc7", label: "製作圖解"),
                        SubTalent(id: "tc8", label: "循序漸進")
                    ]
                ),
                TalentCategory(
                    id: "leadership",
                    title: "影響與領導",
                    subTalents: [
                        SubTalent(id: "le1", label: "帶動氣氛"),
                        SubTalent(id: "le2", label: "說服他人"),
                        SubTalent(id: "le3", label: "號召行動"),
                        SubTalent(id: "le4", label: "承擔責任"),
                        SubTalent(id: "le5", label: "激勵士氣"),
                        SubTalent(id: "le6", label: "展現自信"),
                        SubTalent(id: "le7", label: "描繪願景"),
                        SubTalent(id: "le8", label: "果斷決策")
                    ]
                ),
                TalentCategory(
                    id: "collaboration",
                    title: "協調與整合",
                    subTalents: [
                        SubTalent(id: "co1", label: "喬好資源"),
                        SubTalent(id: "co2", label: "居中斡旋"),
                        SubTalent(id: "co3", label: "找出共識"),
                        SubTalent(id: "co4", label: "填補漏洞"),
                        SubTalent(id: "co5", label: "分配工作"),
                        SubTalent(id: "co6", label: "串接資訊"),
                        SubTalent(id: "co7", label: "配合他人"),
                        SubTalent(id: "co8", label: "維持和諧")
                    ]
                )
            ],
            energyCategories: nil, // Question 1 uses talentCategories
            praiseCategories: nil, // Question 1 uses talentCategories
            learningCategories: nil, // Question 1 uses talentCategories
            fulfillmentCategories: nil // Question 1 uses talentCategories
        ),
        StrengthsQuestion(
            id: 2,
            question: "從事哪些活動時，會讓你感到精神振奮、充滿活力？",
            exampleAnswer: "教導別人新技能時我特別有精神，看到他們進步就很興奮；解決複雜的技術問題讓我越挫越勇；設計創意方案時我可以熬夜不覺得累；主持會議或活動讓我感到特別有活力",
            hints: [
                "想想讓你進入「心流狀態」的活動",
                "回憶哪些工作內容讓你感到時間過得很快",
                "考慮你願意免費去做的事情",
                "思考哪些活動讓你做完後還想繼續做",
                "注意從事哪些活動時你的精神狀態最佳"
            ],
            suggestedKeywords: [], // Not used for Question 2 (uses energyCategories instead)
            keywordHierarchy: [:], // Not used for Question 2 (uses energyCategories instead)
            talentCategories: nil, // Question 2 uses energyCategories
            energyCategories: [
                EnergyCategory(
                    id: "create_zero_to_one",
                    title: "從零到一",
                    subEnergies: [
                        SubEnergy(id: "cz1", label: "打造雛形"),
                        SubEnergy(id: "cz2", label: "建立制度"),
                        SubEnergy(id: "cz3", label: "發起專案"),
                        SubEnergy(id: "cz4", label: "開拓新局"),
                        SubEnergy(id: "cz5", label: "構思草圖"),
                        SubEnergy(id: "cz6", label: "產品孵化"),
                        SubEnergy(id: "cz7", label: "撰寫初稿"),
                        SubEnergy(id: "cz8", label: "搭建框架")
                    ]
                ),
                EnergyCategory(
                    id: "fix_and_solve",
                    title: "排憂解難",
                    subEnergies: [
                        SubEnergy(id: "fs1", label: "排除故障"),
                        SubEnergy(id: "fs2", label: "撲滅火災"),
                        SubEnergy(id: "fs3", label: "解開死結"),
                        SubEnergy(id: "fs4", label: "修復損壞"),
                        SubEnergy(id: "fs5", label: "拯救危機"),
                        SubEnergy(id: "fs6", label: "破解謎題"),
                        SubEnergy(id: "fs7", label: "挽回局面"),
                        SubEnergy(id: "fs8", label: "搞定難題")
                    ]
                ),
                EnergyCategory(
                    id: "optimize_order",
                    title: "優化秩序",
                    subEnergies: [
                        SubEnergy(id: "oo1", label: "梳理流程"),
                        SubEnergy(id: "oo2", label: "提升效率"),
                        SubEnergy(id: "oo3", label: "空間收納"),
                        SubEnergy(id: "oo4", label: "減少浪費"),
                        SubEnergy(id: "oo5", label: "制定規範"),
                        SubEnergy(id: "oo6", label: "系統重構"),
                        SubEnergy(id: "oo7", label: "資料歸檔"),
                        SubEnergy(id: "oo8", label: "標準作業")
                    ]
                ),
                EnergyCategory(
                    id: "deep_dive",
                    title: "深度鑽研",
                    subEnergies: [
                        SubEnergy(id: "dd1", label: "查閱文獻"),
                        SubEnergy(id: "dd2", label: "挖掘真相"),
                        SubEnergy(id: "dd3", label: "追根究底"),
                        SubEnergy(id: "dd4", label: "數據回溯"),
                        SubEnergy(id: "dd5", label: "沉浸閱讀"),
                        SubEnergy(id: "dd6", label: "專注實驗"),
                        SubEnergy(id: "dd7", label: "拆解原理"),
                        SubEnergy(id: "dd8", label: "探尋本質")
                    ]
                ),
                EnergyCategory(
                    id: "compete_win",
                    title: "競技取勝",
                    subEnergies: [
                        SubEnergy(id: "cw1", label: "超越對手"),
                        SubEnergy(id: "cw2", label: "達成業績"),
                        SubEnergy(id: "cw3", label: "贏得比賽"),
                        SubEnergy(id: "cw4", label: "打破紀錄"),
                        SubEnergy(id: "cw5", label: "挑戰榜單"),
                        SubEnergy(id: "cw6", label: "爭取第一"),
                        SubEnergy(id: "cw7", label: "攻克難關"),
                        SubEnergy(id: "cw8", label: "實力輾壓")
                    ]
                ),
                EnergyCategory(
                    id: "lead_influence",
                    title: "引領方向",
                    subEnergies: [
                        SubEnergy(id: "li1", label: "描繪願景"),
                        SubEnergy(id: "li2", label: "凝聚共識"),
                        SubEnergy(id: "li3", label: "指揮調度"),
                        SubEnergy(id: "li4", label: "激勵士氣"),
                        SubEnergy(id: "li5", label: "帶領衝鋒"),
                        SubEnergy(id: "li6", label: "發表宣言"),
                        SubEnergy(id: "li7", label: "說服群眾"),
                        SubEnergy(id: "li8", label: "扭轉風向")
                    ]
                ),
                EnergyCategory(
                    id: "support_nurture",
                    title: "陪伴扶持",
                    subEnergies: [
                        SubEnergy(id: "sn1", label: "傾聽低谷"),
                        SubEnergy(id: "sn2", label: "默默守護"),
                        SubEnergy(id: "sn3", label: "助人成長"),
                        SubEnergy(id: "sn4", label: "提供避風"),
                        SubEnergy(id: "sn5", label: "解決煩惱"),
                        SubEnergy(id: "sn6", label: "成就他人"),
                        SubEnergy(id: "sn7", label: "照料弱勢"),
                        SubEnergy(id: "sn8", label: "心理陪伴")
                    ]
                ),
                EnergyCategory(
                    id: "connect_network",
                    title: "串接人脈",
                    subEnergies: [
                        SubEnergy(id: "cn1", label: "牽線媒合"),
                        SubEnergy(id: "cn2", label: "活躍氣氛"),
                        SubEnergy(id: "cn3", label: "舉辦聚會"),
                        SubEnergy(id: "cn4", label: "破冰交流"),
                        SubEnergy(id: "cn5", label: "資源交換"),
                        SubEnergy(id: "cn6", label: "建立社群"),
                        SubEnergy(id: "cn7", label: "拓展圈子"),
                        SubEnergy(id: "cn8", label: "跨界聯絡")
                    ]
                ),
                EnergyCategory(
                    id: "take_stage",
                    title: "登台展現",
                    subEnergies: [
                        SubEnergy(id: "ts1", label: "享受目光"),
                        SubEnergy(id: "ts2", label: "侃侃而談"),
                        SubEnergy(id: "ts3", label: "肢體表演"),
                        SubEnergy(id: "ts4", label: "散發魅力"),
                        SubEnergy(id: "ts5", label: "掌控全場"),
                        SubEnergy(id: "ts6", label: "鎂光燈下"),
                        SubEnergy(id: "ts7", label: "帶動高潮"),
                        SubEnergy(id: "ts8", label: "現場互動")
                    ]
                ),
                EnergyCategory(
                    id: "push_limits",
                    title: "挑戰極限",
                    subEnergies: [
                        SubEnergy(id: "pl1", label: "踏出舒適"),
                        SubEnergy(id: "pl2", label: "承受高壓"),
                        SubEnergy(id: "pl3", label: "危機應變"),
                        SubEnergy(id: "pl4", label: "腎上腺素"),
                        SubEnergy(id: "pl5", label: "冒險犯難"),
                        SubEnergy(id: "pl6", label: "擁抱未知"),
                        SubEnergy(id: "pl7", label: "豪賭一把"),
                        SubEnergy(id: "pl8", label: "破釜沉舟")
                    ]
                ),
                EnergyCategory(
                    id: "strategic_plan",
                    title: "策劃全局",
                    subEnergies: [
                        SubEnergy(id: "sp1", label: "沙盤推演"),
                        SubEnergy(id: "sp2", label: "制定戰略"),
                        SubEnergy(id: "sp3", label: "佈局未來"),
                        SubEnergy(id: "sp4", label: "資源盤點"),
                        SubEnergy(id: "sp5", label: "風險控管"),
                        SubEnergy(id: "sp6", label: "商業模式"),
                        SubEnergy(id: "sp7", label: "運籌帷幄"),
                        SubEnergy(id: "sp8", label: "宏觀思考")
                    ]
                ),
                EnergyCategory(
                    id: "high_execution",
                    title: "高效推進",
                    subEnergies: [
                        SubEnergy(id: "he1", label: "劃掉清單"),
                        SubEnergy(id: "he2", label: "準時交付"),
                        SubEnergy(id: "he3", label: "按表操課"),
                        SubEnergy(id: "he4", label: "推進進度"),
                        SubEnergy(id: "he5", label: "多工處理"),
                        SubEnergy(id: "he6", label: "掃除障礙"),
                        SubEnergy(id: "he7", label: "完美落地"),
                        SubEnergy(id: "he8", label: "執行到底")
                    ]
                ),
                EnergyCategory(
                    id: "brainstorming",
                    title: "腦力激盪",
                    subEnergies: [
                        SubEnergy(id: "bs1", label: "創意發想"),
                        SubEnergy(id: "bs2", label: "拋磚引玉"),
                        SubEnergy(id: "bs3", label: "碰撞火花"),
                        SubEnergy(id: "bs4", label: "點子接龍"),
                        SubEnergy(id: "bs5", label: "打破常規"),
                        SubEnergy(id: "bs6", label: "異想天開"),
                        SubEnergy(id: "bs7", label: "腦洞大開"),
                        SubEnergy(id: "bs8", label: "概念發散")
                    ]
                ),
                EnergyCategory(
                    id: "refine_aesthetics",
                    title: "雕琢美感",
                    subEnergies: [
                        SubEnergy(id: "ra1", label: "打磨細節"),
                        SubEnergy(id: "ra2", label: "調整色彩"),
                        SubEnergy(id: "ra3", label: "視覺對齊"),
                        SubEnergy(id: "ra4", label: "追求完美"),
                        SubEnergy(id: "ra5", label: "沉浸排版"),
                        SubEnergy(id: "ra6", label: "質感提升"),
                        SubEnergy(id: "ra7", label: "創造氛圍"),
                        SubEnergy(id: "ra8", label: "藝術揮灑")
                    ]
                ),
                EnergyCategory(
                    id: "physical_exertion",
                    title: "揮灑汗水",
                    subEnergies: [
                        SubEnergy(id: "pe1", label: "釋放多巴"),
                        SubEnergy(id: "pe2", label: "突破體能"),
                        SubEnergy(id: "pe3", label: "感受肌肉"),
                        SubEnergy(id: "pe4", label: "戶外走跳"),
                        SubEnergy(id: "pe5", label: "燃燒熱量"),
                        SubEnergy(id: "pe6", label: "節奏律動"),
                        SubEnergy(id: "pe7", label: "身體極限"),
                        SubEnergy(id: "pe8", label: "流汗快感")
                    ]
                ),
                EnergyCategory(
                    id: "immersive_flow",
                    title: "沉浸創作",
                    subEnergies: [
                        SubEnergy(id: "if1", label: "忘我編碼"),
                        SubEnergy(id: "if2", label: "敲擊鍵盤"),
                        SubEnergy(id: "if3", label: "專注手作"),
                        SubEnergy(id: "if4", label: "筆飛墨舞"),
                        SubEnergy(id: "if5", label: "進入心流"),
                        SubEnergy(id: "if6", label: "與世隔絕"),
                        SubEnergy(id: "if7", label: "靈感湧現"),
                        SubEnergy(id: "if8", label: "廢寢忘食")
                    ]
                )
            ],
            praiseCategories: nil, // Question 2 uses energyCategories
            learningCategories: nil, // Question 2 uses energyCategories
            fulfillmentCategories: nil // Question 2 uses energyCategories
        ),
        StrengthsQuestion(
            id: 3,
            question: "別人經常稱讚你哪些方面的表現？",
            exampleAnswer: "朋友常說我很會安慰人，總能在適當時機說出最需要聽的話；同事說我做簡報特別生動有趣；家人說我很有耐心，能把複雜的事情解釋得很清楚；老師說我的創意想法總是很特別",
            hints: [
                "回想最近收到的正面評價",
                "想想別人經常向你尋求幫助的領域",
                "考慮你在團隊中經常被分配的角色",
                "思考別人模仿你或向你學習的事情",
                "注意別人表達羨慕或讚賞的具體能力"
            ],
            suggestedKeywords: ["同理心", "溝通表達", "耐心", "創意", "組織能力", "專業技能", "領導力", "解決問題", "可靠性", "效率", "細心", "責任感", "適應力", "學習能力", "技術能力", "藝術天賦", "運動能力", "語言能力", "記憶力", "分析能力", "決策能力", "執行力", "創新思維", "團隊合作", "時間管理", "壓力管理", "情緒穩定", "積極態度", "樂於助人", "誠實正直", "幽默感", "魅力", "影響力", "說服力", "協調能力", "資源整合", "風險控制", "質量保證", "客戶服務", "銷售能力", "教學能力", "寫作能力", "設計能力", "程式能力", "數據分析", "項目管理", "戰略思考"],
            keywordHierarchy: [:], // Question 3 uses praiseCategories instead
            talentCategories: nil, // Question 3 uses praiseCategories
            energyCategories: nil, // Question 3 uses praiseCategories
            praiseCategories: [
                PraiseCategory(
                    id: "empathy_warmth",
                    title: "溫暖同理",
                    subPraises: [
                        SubPraise(id: "ew1", label: "善於傾聽"),
                        SubPraise(id: "ew2", label: "安慰人心"),
                        SubPraise(id: "ew3", label: "照顧情緒"),
                        SubPraise(id: "ew4", label: "換位思考"),
                        SubPraise(id: "ew5", label: "溫柔包容"),
                        SubPraise(id: "ew6", label: "記住喜好"),
                        SubPraise(id: "ew7", label: "察覺異樣"),
                        SubPraise(id: "ew8", label: "給予支持")
                    ]
                ),
                PraiseCategory(
                    id: "reliable_stable",
                    title: "穩定可靠",
                    subPraises: [
                        SubPraise(id: "rs1", label: "交代必辦"),
                        SubPraise(id: "rs2", label: "說到做到"),
                        SubPraise(id: "rs3", label: "守時重諾"),
                        SubPraise(id: "rs4", label: "讓人安心"),
                        SubPraise(id: "rs5", label: "默默付出"),
                        SubPraise(id: "rs6", label: "扛下責任"),
                        SubPraise(id: "rs7", label: "從不抱怨"),
                        SubPraise(id: "rs8", label: "始終如一")
                    ]
                ),
                PraiseCategory(
                    id: "communication",
                    title: "溝通表達",
                    subPraises: [
                        SubPraise(id: "cm1", label: "口條清晰"),
                        SubPraise(id: "cm2", label: "說服力強"),
                        SubPraise(id: "cm3", label: "說故事強"),
                        SubPraise(id: "cm4", label: "簡報高手"),
                        SubPraise(id: "cm5", label: "深入淺出"),
                        SubPraise(id: "cm6", label: "化解衝突"),
                        SubPraise(id: "cm7", label: "談判議價"),
                        SubPraise(id: "cm8", label: "說話好聽")
                    ]
                ),
                PraiseCategory(
                    id: "sharp_insight",
                    title: "敏銳洞察",
                    subPraises: [
                        SubPraise(id: "si1", label: "一語道破"),
                        SubPraise(id: "si2", label: "看透本質"),
                        SubPraise(id: "si3", label: "直指核心"),
                        SubPraise(id: "si4", label: "邏輯清晰"),
                        SubPraise(id: "si5", label: "抓準盲點"),
                        SubPraise(id: "si6", label: "預判風險"),
                        SubPraise(id: "si7", label: "洞察人心"),
                        SubPraise(id: "si8", label: "客觀中立")
                    ]
                ),
                PraiseCategory(
                    id: "creative_ideas",
                    title: "創新點子",
                    subPraises: [
                        SubPraise(id: "ci1", label: "點子超多"),
                        SubPraise(id: "ci2", label: "腦洞大開"),
                        SubPraise(id: "ci3", label: "視角獨特"),
                        SubPraise(id: "ci4", label: "打破常規"),
                        SubPraise(id: "ci5", label: "充滿創意"),
                        SubPraise(id: "ci6", label: "舉一反三"),
                        SubPraise(id: "ci7", label: "總有驚喜"),
                        SubPraise(id: "ci8", label: "不落俗套")
                    ]
                ),
                PraiseCategory(
                    id: "high_execution",
                    title: "高效執行",
                    subPraises: [
                        SubPraise(id: "he1", label: "動作超快"),
                        SubPraise(id: "he2", label: "說做就做"),
                        SubPraise(id: "he3", label: "絕不拖延"),
                        SubPraise(id: "he4", label: "效率驚人"),
                        SubPraise(id: "he5", label: "雷厲風行"),
                        SubPraise(id: "he6", label: "搞定麻煩"),
                        SubPraise(id: "he7", label: "推進進度"),
                        SubPraise(id: "he8", label: "產出穩定")
                    ]
                ),
                PraiseCategory(
                    id: "perfect_detail",
                    title: "完美細節",
                    subPraises: [
                        SubPraise(id: "pd1", label: "找出錯字"),
                        SubPraise(id: "pd2", label: "魔鬼細節"),
                        SubPraise(id: "pd3", label: "排版精美"),
                        SubPraise(id: "pd4", label: "嚴格把關"),
                        SubPraise(id: "pd5", label: "追求極致"),
                        SubPraise(id: "pd6", label: "考慮周全"),
                        SubPraise(id: "pd7", label: "零出錯率"),
                        SubPraise(id: "pd8", label: "井然有序")
                    ]
                ),
                PraiseCategory(
                    id: "breakthrough_lead",
                    title: "領導破局",
                    subPraises: [
                        SubPraise(id: "bl1", label: "帶領團隊"),
                        SubPraise(id: "bl2", label: "敢做決定"),
                        SubPraise(id: "bl3", label: "穩定軍心"),
                        SubPraise(id: "bl4", label: "指引方向"),
                        SubPraise(id: "bl5", label: "承擔後果"),
                        SubPraise(id: "bl6", label: "突破僵局"),
                        SubPraise(id: "bl7", label: "號召力強"),
                        SubPraise(id: "bl8", label: "凝聚人心")
                    ]
                ),
                PraiseCategory(
                    id: "crisis_management",
                    title: "危機處理",
                    subPraises: [
                        SubPraise(id: "cm_1", label: "臨危不亂"),
                        SubPraise(id: "cm_2", label: "隨機應變"),
                        SubPraise(id: "cm_3", label: "救火隊長"),
                        SubPraise(id: "cm_4", label: "找出解法"),
                        SubPraise(id: "cm_5", label: "越挫越勇"),
                        SubPraise(id: "cm_6", label: "穩定場面"),
                        SubPraise(id: "cm_7", label: "快速止血"),
                        SubPraise(id: "cm_8", label: "應對自如")
                    ]
                ),
                PraiseCategory(
                    id: "vibe_maker",
                    title: "氣氛營造",
                    subPraises: [
                        SubPraise(id: "vm1", label: "帶來歡樂"),
                        SubPraise(id: "vm2", label: "炒熱氣氛"),
                        SubPraise(id: "vm3", label: "幽默風趣"),
                        SubPraise(id: "vm4", label: "化解冰冷"),
                        SubPraise(id: "vm5", label: "充滿活力"),
                        SubPraise(id: "vm6", label: "親和力強"),
                        SubPraise(id: "vm7", label: "破冰達人"),
                        SubPraise(id: "vm8", label: "感染力強")
                    ]
                ),
                PraiseCategory(
                    id: "planning_org",
                    title: "組織策劃",
                    subPraises: [
                        SubPraise(id: "po1", label: "安排妥當"),
                        SubPraise(id: "po2", label: "規劃行程"),
                        SubPraise(id: "po3", label: "掌控全局"),
                        SubPraise(id: "po4", label: "邏輯縝密"),
                        SubPraise(id: "po5", label: "分配任務"),
                        SubPraise(id: "po6", label: "條理分明"),
                        SubPraise(id: "po7", label: "舉辦活動"),
                        SubPraise(id: "po8", label: "資源調度")
                    ]
                ),
                PraiseCategory(
                    id: "aesthetics_taste",
                    title: "審美品味",
                    subPraises: [
                        SubPraise(id: "at1", label: "質感極佳"),
                        SubPraise(id: "at2", label: "穿搭好看"),
                        SubPraise(id: "at3", label: "品味出眾"),
                        SubPraise(id: "at4", label: "懂挑禮物"),
                        SubPraise(id: "at5", label: "佈置空間"),
                        SubPraise(id: "at6", label: "視覺美感"),
                        SubPraise(id: "at7", label: "發現美好"),
                        SubPraise(id: "at8", label: "藝術氣息")
                    ]
                ),
                PraiseCategory(
                    id: "resource_hub",
                    title: "資源整合",
                    subPraises: [
                        SubPraise(id: "rh1", label: "人脈廣闊"),
                        SubPraise(id: "rh2", label: "牽線搭橋"),
                        SubPraise(id: "rh3", label: "找到資源"),
                        SubPraise(id: "rh4", label: "借力使力"),
                        SubPraise(id: "rh5", label: "跨界合作"),
                        SubPraise(id: "rh6", label: "撮合雙方"),
                        SubPraise(id: "rh7", label: "情報中心"),
                        SubPraise(id: "rh8", label: "善用工具")
                    ]
                ),
                PraiseCategory(
                    id: "fast_learner",
                    title: "適應學習",
                    subPraises: [
                        SubPraise(id: "fl1", label: "學得超快"),
                        SubPraise(id: "fl2", label: "融會貫通"),
                        SubPraise(id: "fl3", label: "快速上手"),
                        SubPraise(id: "fl4", label: "靈活變通"),
                        SubPraise(id: "fl5", label: "不畏改變"),
                        SubPraise(id: "fl6", label: "吸收新知"),
                        SubPraise(id: "fl7", label: "觸類旁通"),
                        SubPraise(id: "fl8", label: "隨插即用")
                    ]
                )
            ],
            learningCategories: nil, // Question 3 uses praiseCategories
            fulfillmentCategories: nil // Question 3 uses praiseCategories
        ),
        StrengthsQuestion(
            id: 4,
            question: "你學習什麼類型的事物特別快？",
            exampleAnswer: "我對語言學習特別有天份，能快速掌握發音和語法結構；新的軟體工具我總能很快上手；運動技巧我看幾次示範就能模仿得差不多；音樂節奏我一聽就能跟上",
            hints: [
                "回想學生時期哪些科目學得特別輕鬆",
                "想想工作中哪些新技能你掌握得比同事快",
                "考慮你的學習偏好（視覺、聽覺、動手操作等）",
                "思考哪些類型的資訊你特別容易記住",
                "注意你在哪些領域能夠快速建立理解框架"
            ],
            suggestedKeywords: [], // Not used for Question 4 (uses learningCategories instead)
            keywordHierarchy: [:], // Not used for Question 4 (uses learningCategories instead)
            talentCategories: nil, // Question 4 uses learningCategories
            energyCategories: nil, // Question 4 uses learningCategories
            praiseCategories: nil, // Question 4 uses learningCategories
            learningCategories: [
                LearningCategory(
                    id: "language_comm",
                    title: "外語與溝通",
                    subLearning: [
                        SubLearning(id: "lc1", label: "外語發音"),
                        SubLearning(id: "lc2", label: "語法結構"),
                        SubLearning(id: "lc3", label: "專業術語"),
                        SubLearning(id: "lc4", label: "流行用語"),
                        SubLearning(id: "lc5", label: "肢體語言"),
                        SubLearning(id: "lc6", label: "談判話術"),
                        SubLearning(id: "lc7", label: "演講技巧"),
                        SubLearning(id: "lc8", label: "跨界黑話")
                    ]
                ),
                LearningCategory(
                    id: "digital_tech",
                    title: "數位與工具",
                    subLearning: [
                        SubLearning(id: "dt1", label: "全新軟體"),
                        SubLearning(id: "dt2", label: "快捷鍵法"),
                        SubLearning(id: "dt3", label: "程式邏輯"),
                        SubLearning(id: "dt4", label: "系統架構"),
                        SubLearning(id: "dt5", label: "剪輯排版"),
                        SubLearning(id: "dt6", label: "數據圖表"),
                        SubLearning(id: "dt7", label: "ＡＩ應用"),
                        SubLearning(id: "dt8", label: "儀器操作")
                    ]
                ),
                LearningCategory(
                    id: "physical_motor",
                    title: "肢體與動覺",
                    subLearning: [
                        SubLearning(id: "pm1", label: "運動技巧"),
                        SubLearning(id: "pm2", label: "舞蹈動作"),
                        SubLearning(id: "pm3", label: "樂器指法"),
                        SubLearning(id: "pm4", label: "手工技藝"),
                        SubLearning(id: "pm5", label: "器械操作"),
                        SubLearning(id: "pm6", label: "空間方位"),
                        SubLearning(id: "pm7", label: "烹飪手感"),
                        SubLearning(id: "pm8", label: "肌肉發力")
                    ]
                ),
                LearningCategory(
                    id: "rules_strategy",
                    title: "規則與策略",
                    subLearning: [
                        SubLearning(id: "rs1", label: "遊戲機制"),
                        SubLearning(id: "rs2", label: "商業模式"),
                        SubLearning(id: "rs3", label: "歷史脈絡"),
                        SubLearning(id: "rs4", label: "法律條文"),
                        SubLearning(id: "rs5", label: "流程規範"),
                        SubLearning(id: "rs6", label: "組織架構"),
                        SubLearning(id: "rs7", label: "演算法則"),
                        SubLearning(id: "rs8", label: "賽局推演")
                    ]
                ),
                LearningCategory(
                    id: "numbers_biz",
                    title: "數字與商業",
                    subLearning: [
                        SubLearning(id: "nb1", label: "財務報表"),
                        SubLearning(id: "nb2", label: "投資邏輯"),
                        SubLearning(id: "nb3", label: "成本控管"),
                        SubLearning(id: "nb4", label: "數據規律"),
                        SubLearning(id: "nb5", label: "機率統計"),
                        SubLearning(id: "nb6", label: "定價策略"),
                        SubLearning(id: "nb7", label: "市場趨勢"),
                        SubLearning(id: "nb8", label: "稅務概念")
                    ]
                ),
                LearningCategory(
                    id: "people_psych",
                    title: "人際與心理",
                    subLearning: [
                        SubLearning(id: "pp1", label: "社交禮儀"),
                        SubLearning(id: "pp2", label: "職場生存"),
                        SubLearning(id: "pp3", label: "顧客心理"),
                        SubLearning(id: "pp4", label: "帶人手腕"),
                        SubLearning(id: "pp5", label: "衝突化解"),
                        SubLearning(id: "pp6", label: "察言觀色"),
                        SubLearning(id: "pp7", label: "說服技巧"),
                        SubLearning(id: "pp8", label: "群體動力")
                    ]
                ),
                LearningCategory(
                    id: "aesthetics_taste",
                    title: "美感與品味",
                    subLearning: [
                        SubLearning(id: "at1", label: "色彩搭配"),
                        SubLearning(id: "at2", label: "構圖比例"),
                        SubLearning(id: "at3", label: "穿搭風格"),
                        SubLearning(id: "at4", label: "空間佈置"),
                        SubLearning(id: "at5", label: "攝影技巧"),
                        SubLearning(id: "at6", label: "流行趨勢"),
                        SubLearning(id: "at7", label: "音樂節奏"),
                        SubLearning(id: "at8", label: "擺盤藝術")
                    ]
                ),
                LearningCategory(
                    id: "abstract_concepts",
                    title: "抽象與概念",
                    subLearning: [
                        SubLearning(id: "ac1", label: "哲學思想"),
                        SubLearning(id: "ac2", label: "心理學說"),
                        SubLearning(id: "ac3", label: "物理原理"),
                        SubLearning(id: "ac4", label: "經濟理論"),
                        SubLearning(id: "ac5", label: "品牌定位"),
                        SubLearning(id: "ac6", label: "抽象邏輯"),
                        SubLearning(id: "ac7", label: "未來趨勢"),
                        SubLearning(id: "ac8", label: "宗教玄學")
                    ]
                )
            ],
            fulfillmentCategories: nil // Question 4 uses learningCategories
        ),
        StrengthsQuestion(
            id: 5,
            question: "回想你感到最有成就感的經歷，這些經歷有什麼共同特質？",
            exampleAnswer: "我最有成就感的經歷包括：完成一個複雜的專案並獲得客戶高度認可；幫助一個團隊成員突破瓶頸並看到他成長；成功組織一場大型活動並看到參與者都很享受；解決了一個困擾很久的技術難題",
            hints: [
                "回想讓你感到自豪和滿足的具體經歷",
                "思考這些經歷的共同特質（挑戰性、創造性、幫助他人等）",
                "考慮你在這些經歷中扮演的角色",
                "思考這些經歷對你和他人的影響",
                "注意這些經歷中讓你感到最有價值和意義的部分"
            ],
            suggestedKeywords: [], // Not used for Question 5 (uses fulfillmentCategories instead)
            keywordHierarchy: [:], // Not used for Question 5 (uses fulfillmentCategories instead)
            talentCategories: nil, // Question 5 uses fulfillmentCategories
            energyCategories: nil, // Question 5 uses fulfillmentCategories
            praiseCategories: nil, // Question 5 uses fulfillmentCategories
            learningCategories: nil, // Question 5 uses fulfillmentCategories
            fulfillmentCategories: [
                FulfillmentCategory(
                    id: "challenge_mastery",
                    title: "挑戰與突破",
                    subFulfillment: [
                        SubFulfillment(id: "cm1", label: "突破極限"),
                        SubFulfillment(id: "cm2", label: "戰勝恐懼"),
                        SubFulfillment(id: "cm3", label: "逆境翻盤"),
                        SubFulfillment(id: "cm4", label: "挑戰高壓"),
                        SubFulfillment(id: "cm5", label: "跨越障礙"),
                        SubFulfillment(id: "cm6", label: "谷底反彈"),
                        SubFulfillment(id: "cm7", label: "證明自己"),
                        SubFulfillment(id: "cm8", label: "咬牙撐過")
                    ]
                ),
                FulfillmentCategory(
                    id: "altruism_empower",
                    title: "助人與利他",
                    subFulfillment: [
                        SubFulfillment(id: "ae1", label: "助人成長"),
                        SubFulfillment(id: "ae2", label: "提攜後輩"),
                        SubFulfillment(id: "ae3", label: "雪中送炭"),
                        SubFulfillment(id: "ae4", label: "傳授技能"),
                        SubFulfillment(id: "ae5", label: "見證改變"),
                        SubFulfillment(id: "ae6", label: "陪伴低谷"),
                        SubFulfillment(id: "ae7", label: "啟發靈感"),
                        SubFulfillment(id: "ae8", label: "扭轉人生")
                    ]
                ),
                FulfillmentCategory(
                    id: "creation_legacy",
                    title: "創造與開拓",
                    subFulfillment: [
                        SubFulfillment(id: "cl1", label: "從無到有"),
                        SubFulfillment(id: "cl2", label: "原創設計"),
                        SubFulfillment(id: "cl3", label: "孕育點子"),
                        SubFulfillment(id: "cl4", label: "建立品牌"),
                        SubFulfillment(id: "cl5", label: "發表作品"),
                        SubFulfillment(id: "cl6", label: "實現構想"),
                        SubFulfillment(id: "cl7", label: "留下印記"),
                        SubFulfillment(id: "cl8", label: "顛覆傳統")
                    ]
                ),
                FulfillmentCategory(
                    id: "order_optimization",
                    title: "秩序與優化",
                    subFulfillment: [
                        SubFulfillment(id: "oo1", label: "轉危為安"),
                        SubFulfillment(id: "oo2", label: "梳理混亂"),
                        SubFulfillment(id: "oo3", label: "制定標準"),
                        SubFulfillment(id: "oo4", label: "系統上線"),
                        SubFulfillment(id: "oo5", label: "提升效率"),
                        SubFulfillment(id: "oo6", label: "完美落地"),
                        SubFulfillment(id: "oo7", label: "排除隱患"),
                        SubFulfillment(id: "oo8", label: "解決痛點")
                    ]
                ),
                FulfillmentCategory(
                    id: "connection_synergy",
                    title: "連結與共好",
                    subFulfillment: [
                        SubFulfillment(id: "cs1", label: "促成合作"),
                        SubFulfillment(id: "cs2", label: "辦成活動"),
                        SubFulfillment(id: "cs3", label: "凝聚人心"),
                        SubFulfillment(id: "cs4", label: "建立社群"),
                        SubFulfillment(id: "cs5", label: "深度交心"),
                        SubFulfillment(id: "cs6", label: "達成共識"),
                        SubFulfillment(id: "cs7", label: "化解干戈"),
                        SubFulfillment(id: "cs8", label: "共享榮耀")
                    ]
                ),
                FulfillmentCategory(
                    id: "discovery_truth",
                    title: "探索與解謎",
                    subFulfillment: [
                        SubFulfillment(id: "dt1", label: "解開謎團"),
                        SubFulfillment(id: "dt2", label: "發現規律"),
                        SubFulfillment(id: "dt3", label: "找到解答"),
                        SubFulfillment(id: "dt4", label: "驗證假設"),
                        SubFulfillment(id: "dt5", label: "攻克難題"),
                        SubFulfillment(id: "dt6", label: "洞察先機"),
                        SubFulfillment(id: "dt7", label: "突破盲點"),
                        SubFulfillment(id: "dt8", label: "追求真理")
                    ]
                ),
                FulfillmentCategory(
                    id: "influence_leadership",
                    title: "影響與領導",
                    subFulfillment: [
                        SubFulfillment(id: "il1", label: "帶領團隊"),
                        SubFulfillment(id: "il2", label: "改變現狀"),
                        SubFulfillment(id: "il3", label: "獲得掌聲"),
                        SubFulfillment(id: "il4", label: "制定方向"),
                        SubFulfillment(id: "il5", label: "贏得認可"),
                        SubFulfillment(id: "il6", label: "擴大影響"),
                        SubFulfillment(id: "il7", label: "成為標竿"),
                        SubFulfillment(id: "il8", label: "說服大眾")
                    ]
                ),
                FulfillmentCategory(
                    id: "tangible_rewards",
                    title: "成果與回報",
                    subFulfillment: [
                        SubFulfillment(id: "tr1", label: "業績達標"),
                        SubFulfillment(id: "tr2", label: "賺取財富"),
                        SubFulfillment(id: "tr3", label: "獲得獎項"),
                        SubFulfillment(id: "tr4", label: "拿下訂單"),
                        SubFulfillment(id: "tr5", label: "晉升上位"),
                        SubFulfillment(id: "tr6", label: "擴大版圖"),
                        SubFulfillment(id: "tr7", label: "資源倍增"),
                        SubFulfillment(id: "tr8", label: "贏得比賽")
                    ]
                ),
                FulfillmentCategory(
                    id: "autonomy_freedom",
                    title: "自由與自主",
                    subFulfillment: [
                        SubFulfillment(id: "af1", label: "打破常規"),
                        SubFulfillment(id: "af2", label: "獨當一面"),
                        SubFulfillment(id: "af3", label: "自由調度"),
                        SubFulfillment(id: "af4", label: "擺脫束縛"),
                        SubFulfillment(id: "af5", label: "捍衛理念"),
                        SubFulfillment(id: "af6", label: "不受干擾"),
                        SubFulfillment(id: "af7", label: "堅持自我"),
                        SubFulfillment(id: "af8", label: "實現自我")
                    ]
                )
            ]
        )
    ]
}
