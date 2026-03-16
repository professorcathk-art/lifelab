import Foundation

// MARK: - Data Models
struct SubInterest: Identifiable, Hashable {
    let id: String
    let label: String
}

struct InterestCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let subInterests: [SubInterest]
}

// MARK: - Interest Dictionary
struct InterestDictionary {
    static let shared = InterestDictionary()
    
    // New structure with shortened 4-character labels
    let categories: [InterestCategory] = [
        InterestCategory(
            id: "design",
            title: "設計與美學",
            subInterests: [
                SubInterest(id: "d1", label: "品牌視覺"),
                SubInterest(id: "d2", label: "空間規劃"),
                SubInterest(id: "d3", label: "產品外觀"),
                SubInterest(id: "d4", label: "色彩排版"),
                SubInterest(id: "d5", label: "動態設計"),
                SubInterest(id: "d6", label: "實體包裝"),
                SubInterest(id: "d7", label: "時尚穿搭"),
                SubInterest(id: "d8", label: "服務體驗"),
                SubInterest(id: "d9", label: "介面優化"),
                SubInterest(id: "d10", label: "展覽策劃")
            ]
        ),
        InterestCategory(
            id: "writing",
            title: "文字與敘事",
            subInterests: [
                SubInterest(id: "w1", label: "撰寫故事"),
                SubInterest(id: "w2", label: "概念轉譯"),
                SubInterest(id: "w3", label: "商業文案"),
                SubInterest(id: "w4", label: "深度報導"),
                SubInterest(id: "w5", label: "劇本對白"),
                SubInterest(id: "w6", label: "知識提煉"),
                SubInterest(id: "w7", label: "詩詞創作"),
                SubInterest(id: "w8", label: "技術文件"),
                SubInterest(id: "w9", label: "演講撰稿"),
                SubInterest(id: "w10", label: "社群經營")
            ]
        ),
        InterestCategory(
            id: "music",
            title: "音樂與聲音",
            subInterests: [
                SubInterest(id: "m1", label: "作曲編曲"),
                SubInterest(id: "m2", label: "樂器演奏"),
                SubInterest(id: "m3", label: "混音工程"),
                SubInterest(id: "m4", label: "數位製作"),
                SubInterest(id: "m5", label: "歌唱表演"),
                SubInterest(id: "m6", label: "氣氛營造"),
                SubInterest(id: "m7", label: "音樂治療"),
                SubInterest(id: "m8", label: "聲音敘事"),
                SubInterest(id: "m9", label: "影視配樂"),
                SubInterest(id: "m10", label: "音樂評論")
            ]
        ),
        InterestCategory(
            id: "visuals",
            title: "影像與視覺",
            subInterests: [
                SubInterest(id: "v1", label: "人像攝影"),
                SubInterest(id: "v2", label: "風景捕捉"),
                SubInterest(id: "v3", label: "商業攝影"),
                SubInterest(id: "v4", label: "影片導演"),
                SubInterest(id: "v5", label: "影音剪輯"),
                SubInterest(id: "v6", label: "街頭紀實"),
                SubInterest(id: "v7", label: "活動紀錄"),
                SubInterest(id: "v8", label: "航拍視角"),
                SubInterest(id: "v9", label: "微距探索"),
                SubInterest(id: "v10", label: "視覺企劃")
            ]
        ),
        InterestCategory(
            id: "software",
            title: "軟體與開發",
            subInterests: [
                SubInterest(id: "s1", label: "網頁開發"),
                SubInterest(id: "s2", label: "App開發"),
                SubInterest(id: "s3", label: "數據分析"),
                SubInterest(id: "s4", label: "訓練AI"),
                SubInterest(id: "s5", label: "區塊鏈"),
                SubInterest(id: "s6", label: "遊戲邏輯"),
                SubInterest(id: "s7", label: "雲端架構"),
                SubInterest(id: "s8", label: "資訊安全"),
                SubInterest(id: "s9", label: "流程自動化"),
                SubInterest(id: "s10", label: "開源貢獻")
            ]
        ),
        InterestCategory(
            id: "education",
            title: "教育與啟發",
            subInterests: [
                SubInterest(id: "e1", label: "教練輔導"),
                SubInterest(id: "e2", label: "課程設計"),
                SubInterest(id: "e3", label: "知識教學"),
                SubInterest(id: "e4", label: "兒童陪伴"),
                SubInterest(id: "e5", label: "企業培訓"),
                SubInterest(id: "e6", label: "線上課程"),
                SubInterest(id: "e7", label: "語言教學"),
                SubInterest(id: "e8", label: "職涯引導"),
                SubInterest(id: "e9", label: "特殊教育"),
                SubInterest(id: "e10", label: "終身學習")
            ]
        ),
        InterestCategory(
            id: "business",
            title: "商業與策略",
            subInterests: [
                SubInterest(id: "b1", label: "從零創業"),
                SubInterest(id: "b2", label: "成長策略"),
                SubInterest(id: "b3", label: "市場行銷"),
                SubInterest(id: "b4", label: "團隊管理"),
                SubInterest(id: "b5", label: "財務分析"),
                SubInterest(id: "b6", label: "投資研究"),
                SubInterest(id: "b7", label: "品牌建立"),
                SubInterest(id: "b8", label: "商業談判"),
                SubInterest(id: "b9", label: "電商營運"),
                SubInterest(id: "b10", label: "資源整合")
            ]
        ),
        InterestCategory(
            id: "art",
            title: "藝術與創作",
            subInterests: [
                SubInterest(id: "a1", label: "手繪素描"),
                SubInterest(id: "a2", label: "立體雕塑"),
                SubInterest(id: "a3", label: "數位插畫"),
                SubInterest(id: "a4", label: "動畫角色"),
                SubInterest(id: "a5", label: "書法字體"),
                SubInterest(id: "a6", label: "複合媒材"),
                SubInterest(id: "a7", label: "裝置藝術"),
                SubInterest(id: "a8", label: "表演藝術"),
                SubInterest(id: "a9", label: "藝術策展"),
                SubInterest(id: "a10", label: "工藝傳承")
            ]
        ),
        InterestCategory(
            id: "sports",
            title: "體能與運動",
            subInterests: [
                SubInterest(id: "sp1", label: "肌力訓練"),
                SubInterest(id: "sp2", label: "瑜珈伸展"),
                SubInterest(id: "sp3", label: "長跑耐力"),
                SubInterest(id: "sp4", label: "團隊競技"),
                SubInterest(id: "sp5", label: "極限運動"),
                SubInterest(id: "sp6", label: "水上活動"),
                SubInterest(id: "sp7", label: "登山健行"),
                SubInterest(id: "sp8", label: "舞蹈肢體"),
                SubInterest(id: "sp9", label: "武術防身"),
                SubInterest(id: "sp10", label: "賽事分析")
            ]
        ),
        InterestCategory(
            id: "culinary",
            title: "餐飲與生活",
            subInterests: [
                SubInterest(id: "c1", label: "烘焙甜點"),
                SubInterest(id: "c2", label: "料理研發"),
                SubInterest(id: "c3", label: "營養規劃"),
                SubInterest(id: "c4", label: "品酒調酒"),
                SubInterest(id: "c5", label: "咖啡萃取"),
                SubInterest(id: "c6", label: "茶道文化"),
                SubInterest(id: "c7", label: "飲食文化"),
                SubInterest(id: "c8", label: "空間經營"),
                SubInterest(id: "c9", label: "美食評論"),
                SubInterest(id: "c10", label: "永續飲食")
            ]
        ),
        InterestCategory(
            id: "exploration",
            title: "探索與文化",
            subInterests: [
                SubInterest(id: "ec1", label: "背包旅行"),
                SubInterest(id: "ec2", label: "異國文化"),
                SubInterest(id: "ec3", label: "歷史考證"),
                SubInterest(id: "ec4", label: "古蹟建築"),
                SubInterest(id: "ec5", label: "田野調查"),
                SubInterest(id: "ec6", label: "城市秘境"),
                SubInterest(id: "ec7", label: "博物館"),
                SubInterest(id: "ec8", label: "宗教信仰"),
                SubInterest(id: "ec9", label: "旅居生活"),
                SubInterest(id: "ec10", label: "荒野求生")
            ]
        ),
        InterestCategory(
            id: "knowledge",
            title: "知識與研究",
            subInterests: [
                SubInterest(id: "k1", label: "歷史脈絡"),
                SubInterest(id: "k2", label: "哲學思辨"),
                SubInterest(id: "k3", label: "行為分析"),
                SubInterest(id: "k4", label: "總體經濟"),
                SubInterest(id: "k5", label: "社會觀察"),
                SubInterest(id: "k6", label: "跨域整合"),
                SubInterest(id: "k7", label: "學術研究"),
                SubInterest(id: "k8", label: "未來趨勢"),
                SubInterest(id: "k9", label: "神話文學"),
                SubInterest(id: "k10", label: "情報驗證")
            ]
        ),
        InterestCategory(
            id: "people",
            title: "人際與社群",
            subInterests: [
                SubInterest(id: "p1", label: "建立關係"),
                SubInterest(id: "p2", label: "衝突協商"),
                SubInterest(id: "p3", label: "團隊凝聚"),
                SubInterest(id: "p4", label: "拓展人脈"),
                SubInterest(id: "p5", label: "活動主持"),
                SubInterest(id: "p6", label: "傾聽同理"),
                SubInterest(id: "p7", label: "社群經營"),
                SubInterest(id: "p8", label: "危機處理"),
                SubInterest(id: "p9", label: "實體聚會"),
                SubInterest(id: "p10", label: "社區營造")
            ]
        ),
        InterestCategory(
            id: "tech",
            title: "科技與創新",
            subInterests: [
                SubInterest(id: "t1", label: "最新科技"),
                SubInterest(id: "t2", label: "前沿趨勢"),
                SubInterest(id: "t3", label: "物聯網"),
                SubInterest(id: "t4", label: "AR/VR"),
                SubInterest(id: "t5", label: "智慧家電"),
                SubInterest(id: "t6", label: "無人機"),
                SubInterest(id: "t7", label: "生技醫療"),
                SubInterest(id: "t8", label: "太空科學"),
                SubInterest(id: "t9", label: "科技倫理"),
                SubInterest(id: "t10", label: "創客DIY")
            ]
        ),
        InterestCategory(
            id: "wellness",
            title: "身心與療癒",
            subInterests: [
                SubInterest(id: "wh1", label: "心理諮商"),
                SubInterest(id: "wh2", label: "冥想正念"),
                SubInterest(id: "wh3", label: "自然療法"),
                SubInterest(id: "wh4", label: "情緒釋放"),
                SubInterest(id: "wh5", label: "芳香療法"),
                SubInterest(id: "wh6", label: "睡眠優化"),
                SubInterest(id: "wh7", label: "抗老長壽"),
                SubInterest(id: "wh8", label: "物理治療"),
                SubInterest(id: "wh9", label: "身心靈"),
                SubInterest(id: "wh10", label: "健康推廣")
            ]
        ),
        InterestCategory(
            id: "science",
            title: "科學與分析",
            subInterests: [
                SubInterest(id: "sa1", label: "實驗設計"),
                SubInterest(id: "sa2", label: "數據規律"),
                SubInterest(id: "sa3", label: "觀測生物"),
                SubInterest(id: "sa4", label: "化學合成"),
                SubInterest(id: "sa5", label: "天文觀測"),
                SubInterest(id: "sa6", label: "地理氣候"),
                SubInterest(id: "sa7", label: "數學演算"),
                SubInterest(id: "sa8", label: "物理定律"),
                SubInterest(id: "sa9", label: "科普轉譯"),
                SubInterest(id: "sa10", label: "儀器操作")
            ]
        ),
        InterestCategory(
            id: "language",
            title: "語言與跨文化",
            subInterests: [
                SubInterest(id: "l1", label: "多國語言"),
                SubInterest(id: "l2", label: "口譯傳譯"),
                SubInterest(id: "l3", label: "文字翻譯"),
                SubInterest(id: "l4", label: "外語教學"),
                SubInterest(id: "l5", label: "跨界溝通"),
                SubInterest(id: "l6", label: "語言學"),
                SubInterest(id: "l7", label: "商務談判"),
                SubInterest(id: "l8", label: "本土語"),
                SubInterest(id: "l9", label: "軟體在地化"),
                SubInterest(id: "l10", label: "文化外交")
            ]
        ),
        InterestCategory(
            id: "nature",
            title: "自然與永續",
            subInterests: [
                SubInterest(id: "n1", label: "生態保育"),
                SubInterest(id: "n2", label: "氣候倡議"),
                SubInterest(id: "n3", label: "再生能源"),
                SubInterest(id: "n4", label: "零廢棄"),
                SubInterest(id: "n5", label: "有機農業"),
                SubInterest(id: "n6", label: "ESG規劃"),
                SubInterest(id: "n7", label: "生態觀察"),
                SubInterest(id: "n8", label: "森林療癒"),
                SubInterest(id: "n9", label: "海洋保育"),
                SubInterest(id: "n10", label: "永續材料")
            ]
        ),
        InterestCategory(
            id: "making",
            title: "實作與製造",
            subInterests: [
                SubInterest(id: "ma1", label: "木工傢俱"),
                SubInterest(id: "ma2", label: "機械結構"),
                SubInterest(id: "ma3", label: "3D列印"),
                SubInterest(id: "ma4", label: "電路焊接"),
                SubInterest(id: "ma5", label: "金工珠寶"),
                SubInterest(id: "ma6", label: "服裝打版"),
                SubInterest(id: "ma7", label: "皮革工藝"),
                SubInterest(id: "ma8", label: "舊物改造"),
                SubInterest(id: "ma9", label: "載具改裝"),
                SubInterest(id: "ma10", label: "模型微縮")
            ]
        ),
        InterestCategory(
            id: "advocacy",
            title: "社會與倡議",
            subInterests: [
                SubInterest(id: "ad1", label: "公共政策"),
                SubInterest(id: "ad2", label: "弱勢權益"),
                SubInterest(id: "ad3", label: "非營利"),
                SubInterest(id: "ad4", label: "社會企業"),
                SubInterest(id: "ad5", label: "勞工權益"),
                SubInterest(id: "ad6", label: "性別平權"),
                SubInterest(id: "ad7", label: "地方創生"),
                SubInterest(id: "ad8", label: "動物權益"),
                SubInterest(id: "ad9", label: "人道救援"),
                SubInterest(id: "ad10", label: "公民監督")
            ]
        )
    ]
    
    // Legacy support - keep for backward compatibility
    private let legacyDictionary: [String: [String]] = [
        "設計": ["UI設計", "平面設計", "產品設計", "品牌設計", "視覺設計", "網頁設計", "動畫設計", "包裝設計", "空間設計", "時尚設計"],
        "寫作": ["文案寫作", "內容創作", "小說寫作", "技術寫作", "創意寫作", "詩歌", "劇本寫作", "新聞寫作", "學術寫作", "博客寫作"],
        "音樂": ["作曲", "演奏", "音樂製作", "音樂教育", "音響工程", "歌唱", "編曲", "音樂評論", "音樂治療", "DJ"],
        "攝影": ["人像攝影", "風景攝影", "商業攝影", "後期製作", "影片製作", "街頭攝影", "婚禮攝影", "產品攝影", "航拍", "微距攝影"],
        "程式": ["網頁開發", "移動應用開發", "數據分析", "人工智慧", "區塊鏈", "機器學習", "雲端計算", "資訊安全", "遊戲開發", "自動化"],
        "教育": ["教學", "課程設計", "培訓", "輔導", "知識分享", "線上教育", "語言教學", "技能培訓", "兒童教育", "成人教育"],
        "商業": ["創業", "行銷", "管理", "策略規劃", "投資", "財務分析", "市場研究", "品牌管理", "電子商務", "顧問"],
        "藝術": ["繪畫", "雕塑", "插畫", "動畫", "數位藝術", "書法", "版畫", "裝置藝術", "行為藝術", "公共藝術"],
        "運動": ["健身", "瑜伽", "跑步", "球類運動", "戶外活動", "游泳", "自行車", "登山", "舞蹈", "武術"],
        "烹飪": ["烘焙", "料理", "食譜開發", "美食評論", "營養規劃", "甜點製作", "調酒", "咖啡", "茶藝", "素食料理"],
        "旅行": ["背包旅行", "文化探索", "攝影旅行", "冒險旅行", "深度旅遊", "城市探索", "自然探索", "歷史之旅", "美食之旅", "極地探險"],
        "閱讀": ["文學", "歷史", "科學", "哲學", "心理學", "經濟學", "社會學", "藝術史", "傳記", "科幻"],
        "社交": ["人際關係", "溝通技巧", "領導力", "團隊合作", "公關", "演講", "談判", "社交媒體", "網絡建立", "社區服務"],
        "科技": ["新科技探索", "產品評測", "技術研究", "創新應用", "科技趨勢", "物聯網", "虛擬實境", "擴增實境", "量子計算", "生物科技"],
        "健康": ["養生", "心理健康", "營養學", "運動醫學", "健康管理", "冥想", "正念", "睡眠優化", "壓力管理", "長壽研究"],
        "科學": ["物理學", "化學", "生物學", "天文學", "地質學", "數學", "統計學", "研究", "實驗設計", "科學傳播"],
        "語言": ["英語", "日語", "韓語", "法語", "西班牙語", "德語", "翻譯", "口譯", "語言教學", "語言學習"],
        "創意": ["腦力激盪", "創新思維", "問題解決", "設計思考", "創意寫作", "視覺化", "概念設計", "原型製作", "用戶體驗", "服務設計"],
        "媒體": ["影片製作", "播客", "直播", "內容創作", "社交媒體", "數位行銷", "品牌故事", "視覺敘事", "紀錄片", "廣告"],
        "環境": ["環保", "永續發展", "再生能源", "氣候變遷", "生態保護", "綠色生活", "零廢棄", "有機農業", "環境教育", "碳足跡"]
    ]
    
    func getRelatedKeywords(for keyword: String) -> [String] {
        return legacyDictionary[keyword] ?? []
    }
    
    func getAllKeywords() -> [String] {
        return Array(legacyDictionary.keys)
    }
    
    // New methods for category-based access
    func getCategory(byId id: String) -> InterestCategory? {
        return categories.first { $0.id == id }
    }
    
    func getCategory(byTitle title: String) -> InterestCategory? {
        return categories.first { $0.title == title }
    }
}
