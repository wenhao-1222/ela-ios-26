//
//  ForumPublishSqlite.swift
//  lns
//
//  Created by Elavatine on 2025/2/21.
//  将本地草稿箱的帖子详情，存到本地数据库


import SQLite

class ForumPublishSqlite {
    
    static let shared = ForumPublishSqlite()
    
    private var db: Connection?
    private let table = Table("forum_publish")
    private let uid   = Expression<String>(value: "uid")
    private let ctime = Expression<String>(value: "ctime")
    private let title = Expression<String>(value: "title")
    private let content = Expression<String>(value: "content")
    private let type = Expression<String>(value:"type")//帖子类型  2  投票帖，1 普通帖
    private let commentable = Expression<String>(value: "commentable")//能否评论  默认1
    private let isUpload = Expression<String>(value: "isUpload")//发布状态   0   不发布   ，1  待发布   2 已发布  4 获取视频资源异常
    
    //image  or  video ，非投票帖时，此值非空
    //1 图片 + 文字  2 视频 + 文字 3 纯文字帖
    private let forumType =  Expression<String>(value: "content_type")
    private let videoLocalUrl = Expression<String>(value: "video")//本地video路径，将视频存到本地，此字段存的是本地视频路径
    private let videoUrl = Expression<String>(value: "video_url")//视频路径，OSS的路径
    private let imagesLocal = Expression<String>(value: "images")//帖子图片路径，存有路径数组的字符串
    private let imagesUrl = Expression<String>(value: "images_url")//帖子图片路径，已上传到OSS的路径
    
    private let videoCoverImg = Expression<String>(value: "video_cover_img")//视频帖，封面图
    private let videoCoverUrl = Expression<String>(value: "video_cover_url")//视频帖，封面图 oss链接
    private let videoCoverImgWidth = Expression<String>(value: "video_cover_img_w")//视频帖，封面图宽
    private let videoCoverImgHeight = Expression<String>(value: "video_cover_img_h")//视频帖，封面图高
    private let videoWidth = Expression<String>(value: "video_w")//视频帖，宽
    private let videoHeight = Expression<String>(value: "video_h")//视频帖，高
    private let videoDuration = Expression<String>(value: "video_duration")//视频帖，高
    private let videoOriginUrl = Expression<String>(value: "video_origin_url")//视频 在完成压缩前，本地url路径
    private let videoCompressProgress = Expression<String>(value: "video_compress_progress")//视频 在完成压缩前，本地url路径
    
    private let isPoll = Expression<String>(value: "ispoll")
    private let pollType = Expression<String>(value: "poll_type")//投票类型  2 多选   1 单选
    private let pollTitle = Expression<String>(value: "poll_title")//投票标题
    private let pollHasImage = Expression<String>(value: "poll_has_image")//是否图文  1  带图   0  无图
    private let pollShowResult = Expression<String>(value: "poll_show_result")//是否显示投票结果，默认 1
    private let pollOptionThreshold = Expression<String>(value: "optionthreshold")//投票可选选项  多选
    private let pollItems = Expression<String>(value: "polls")//帖子投票信息
    private let pollItemsForUpload = Expression<String>(value: "poll_items")//帖子投票信息 ，处理后的投票贴选项信息
    
    private let progress = Expression<String>(value: "progress")//帖子发布进度
    
    class func getInstance() -> ForumPublishSqlite
    {
        if(shared.db == nil)
        {
            do{
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileUrl = documentDirectory.appendingPathComponent("elavatine").appendingPathExtension("sqlite3")
                shared.db = try Connection(fileUrl.path)
                shared.createTable()
            }catch{
                DLLog(message:"DB Error \(error)")
            }
        }
        return shared
    }
    func createTable() {
        do {
            try db?.run(table.create { t in
                t.column(uid)
                t.column(ctime)
                t.column(title)
                t.column(content)
                t.column(type)
                t.column(commentable)
                t.column(isUpload)
                t.column(forumType)
                t.column(videoLocalUrl)
                t.column(videoUrl)
                t.column(imagesLocal)
                t.column(imagesUrl)
                t.column(videoCoverImg)
                t.column(videoCoverImgWidth)
                t.column(videoCoverImgHeight)
                t.column(videoWidth)
                t.column(videoHeight)
                t.column(isPoll)
                t.column(pollType)
                t.column(pollTitle)
                t.column(pollHasImage)
                t.column(pollShowResult)
                t.column(pollOptionThreshold)
                t.column(pollItems)
                t.column(pollItemsForUpload)
                t.column(progress)
                t.column(videoCoverUrl)
                t.column(videoOriginUrl)
                t.column(videoCompressProgress)
                t.column(videoDuration)
                t.primaryKey(uid,ctime)
            })
        } catch {
            DLLog(message:"Unable to create table <forum_publish>")
            isNewColumnExist(columnNames: "video_duration")
        }
        
    }
    func isNewColumnExist(columnNames:String) {
        do {
            var isExist = false
            let expression = table.expression
            let colunmnNames = try db?.prepare(expression.template,expression.bindings).columnNames
            if colunmnNames?.count ?? 0 > 0 {
                for i in 0..<(colunmnNames?.count ?? 0) {
                    let colName = colunmnNames?[i]as? String ?? ""
                    if colName == columnNames {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist {
                do {
                    try db?.execute("alter table forum_publish add column '\(columnNames)' TEXT DEFAULT ''")
                    print("add----success")
                } catch {
                    print("add----Error")
                }
            }
        } catch {
            
        }
    }
    //MARK: SQL语句插入数据
    func insertDataUseSql(cTime: String) {
        do {
            try db?.execute("INSERT INTO forum_publish (uid,ctime,title,content,type,commentable,isUpload,content_type,video,video_url,images,images_url,video_cover_img,video_cover_img_w,video_cover_img_h,video_w,video_h,ispoll,poll_type,poll_title,poll_has_image,poll_show_result,optionthreshold,polls,poll_items,progress,video_cover_url,video_origin_url,video_compress_progress,video_duration) VALUES ('\(UserInfoModel.shared.uId)','\(cTime)','','','1','1','0','1','','','','','','','','','','0','1','','0','1','1','','','','','','','')")
            DLLog(message: "SQL语句插入  ----  success <forum_publish>")
        }catch{
            DLLog(message: "SQL语句插入  ----  执行失败 <forum_publish>")
        }
    }
    func deleteForum(ctime:String) {
        do {
            try db?.execute("DELETE FROM forum_publish WHERE uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ctime)';")
        }catch{
        }
    }
    //更新上传进度
    func updateProgress(cTime:String? = ForumPublishManager.shared.cTime,data:String) {
        do {
            let updateSql = "UPDATE forum_publish SET"
            + " progress = '\(data)'"
            + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime ?? ForumPublishManager.shared.cTime)');"
            
            try self.db?.execute(updateSql)
        } catch {
            DLLog(message: "更新上传进度 <forum_publish> :   (\(cTime ?? ForumPublishManager.shared.cTime)) -- (progress)  :  \(data)")
        }
    }
    //MARK: 更新单条数据
    func updateSingleData(columnName:String,data:String,cTime:String? = ForumPublishManager.shared.cTime) {
        do {
            let updateSql = "UPDATE forum_publish SET"
            + " \(columnName) = '\(data)'"
            + " WHERE (uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(cTime ?? ForumPublishManager.shared.cTime)');"
            
            try self.db?.execute(updateSql)
        } catch {
            DLLog(message: "更新单条数据Fail <forum_publish> :   (\(cTime ?? ForumPublishManager.shared.cTime)) -- (\(columnName))  :  \(data)")
        }
    }
    func queryVideoPath() -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ForumPublishManager.shared.cTime)'))"){
                for row in rows{
                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["videoFilePath":row[8]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryProgress(ctime:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ctime)'))"){
                for row in rows{
//                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["progress":row[25]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryVideoDuration(ctime:String) -> String {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ctime)'))"){
                for row in rows{
//                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["duration":row[29]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        DLLog(message: "\(dict.stringValueForKey(key: "duration"))")
        return String(format: "%.0f", dict.doubleValueForKey(key: "duration"))
    }
    func queryCompressProgress(ctime:String) -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ctime)'))"){
                for row in rows{
//                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["progress":row[28]as? String ?? "",
                            "contentType":row[7]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryVideoCoverPath(ctime:String?) -> NSDictionary {
        var dict = NSDictionary()
        let queryCtime = ctime != nil ? ctime : ForumPublishManager.shared.cTime
        do {
            DLLog(message: "queryVideoCoverPath:\(queryCtime ?? "")")
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(queryCtime ?? "")'))"){
                for row in rows{
                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["videoCoverFilePath":row[12]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    ///查询正文图片
    func queryContentImgsPath() -> NSDictionary {
        var dict = NSDictionary()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE ((uid == '\(UserInfoModel.shared.uId)' AND ctime == '\(ForumPublishManager.shared.cTime)'))"){
                for row in rows{
                    DLLog(message: "queryVideoCoverPath SELECT RESULT:\(row)")
                    dict = ["images":row[12]as? String ?? ""]
                }
            }
        } catch {
//            return models
        }
        
        return dict
    }
    func queryTableAll() -> NSArray {
        let models = NSMutableArray()
        do {
            if let rows = try db?.prepare("SELECT * FROM forum_publish WHERE uid == '\(UserInfoModel.shared.uId)' ORDER BY ctime DESC"){
                DLLog(message: "---- \(rows)")
                for row in rows{
                    let dict = ["ctime":row[1]as? String ?? "",
                                "title":row[2]as? String ?? "",
                                "content":row[3]as? String ?? "",
                                "type":row[4]as? String ?? "",
                                "commentable":row[5]as? String ?? "",
                                "isUpload":row[6]as? String ?? "",
                                "contentType":row[7]as? String ?? "",
                                "video":row[8]as? String ?? "",
                                "videoUrl":row[9]as? String ?? "",
                                "images":row[10]as? String ?? "",
                                "imagesUrl":row[11]as? String ?? "",
                                "videoCoverImg":row[12]as? String ?? "",
                                "videoCoverImgW":row[13]as? String ?? "",
                                "videoCoverImgH":row[14]as? String ?? "",
                                "videoW":row[15]as? String ?? "",
                                "videoH":row[16]as? String ?? "",
                                "isPoll":row[17]as? String ?? "",
                                "pollType":row[18]as? String ?? "",
                                "pollTitle":row[19]as? String ?? "",
                                "pollHasImg":row[20]as? String ?? "",
                                "pollShowResult":row[21]as? String ?? "",
                                "pollOptions":row[22]as? String ?? "",
                                "polls":row[23]as? String ?? "",
                                "pollsItem":row[24]as? String ?? "",
                                "progress":row[25]as? String ?? "",
                                "videoCoverUrl":row[26]as? String ?? "",
                                "videoOriginUrl":row[27]as? String ?? "",
                                "videoCompressProgress":row[28]as? String ?? "",
                                "videoDuration":row[29]as? String ?? ""] as [String:String]
                    models.add(dict)
                }
            }
        }catch {
            DLLog(message:"查询错误")
        }
        return models
    }
}
