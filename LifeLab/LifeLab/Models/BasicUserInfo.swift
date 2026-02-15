import Foundation

struct BasicUserInfo: Codable {
    var region: String? // 居住地區
    var age: Int? // 年齡
    var name: String? // 稱呼
    var occupation: String? // 職業
    var annualSalaryUSD: Int? // 年薪（USD，可選）
    var familyStatus: FamilyStatus? // 家庭狀況
    var education: EducationLevel? // 學歷
    
    enum FamilyStatus: String, Codable, CaseIterable {
        case single = "單身"
        case marriedNoKids = "已婚無子女"
        case marriedWithKids = "已婚有子女"
        case divorced = "離婚"
        case other = "其他"
    }
    
    enum EducationLevel: String, Codable, CaseIterable {
        case highSchool = "高中"
        case associate = "專科"
        case bachelor = "學士"
        case master = "碩士"
        case doctorate = "博士"
        case other = "其他"
    }
    
    init(region: String? = nil, age: Int? = nil, name: String? = nil, occupation: String? = nil, annualSalaryUSD: Int? = nil, familyStatus: FamilyStatus? = nil, education: EducationLevel? = nil) {
        self.region = region
        self.age = age
        self.name = name
        self.occupation = occupation
        self.annualSalaryUSD = annualSalaryUSD
        self.familyStatus = familyStatus
        self.education = education
    }
}
