//
//  InputViewController.swift
//  TodoDatePickerProject
//
//  Created by 原田茂大 on 2019/12/01.
//  Copyright © 2019 geshi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var todo: Todo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let t = todo{
            //編集できた場合
            textField.text = t.title
            textView.text = t.body
            //button.setTitle("更新", for: .normal)
        }//else{
            //textView.text = d.body
            //button.setTitle("追加", for: .normal)
            
        //}
        
        self.textView.layer.borderColor = UIColor.black.cgColor
        self.textView.layer.borderWidth = 2
        
    }
    
    @IBAction func didClickbutton(_ sender: UIButton) {
        
        //タイトルが空かチェック
        if isNullOrEmpty(text: textField.text){
            //textField.textがnilまたは空の場合
            return //処理を中断
        }
        
        //本文が空かチェック
        if isNullOrEmpty(text: textView.text){
            //textView.textがnilまたは空の場合
            return
        }
        
        if let t = todo{
            updateTodo(newTitle: textField.text!, newBody: textView.text, todo: t)
        }else{
       //日記を保存する
        createNewTodo(title: textField.text!, body: textView.text)
        }
        //前の画面に戻る
        navigationController?.popViewController(animated: true)
        
        //通知の作成
        let notificationContent = UNMutableNotificationContent()
        //通知のタイトルに画面で入力されたタイトルを設定
        notificationContent.title = textField.text!
        //通知の本文に画面で入力された本文を設定
        notificationContent.body = textView.text!
        //通知音にデフォルト音声を設定
        notificationContent.sound = .default
        
        //通知時間の作成
        var notificationTime = DateComponents()
        let calender = Calendar.current //現在時間を取得
        
        //時間の設定
        notificationTime.hour = calender.component(.hour, from:datePicker.date)
        notificationTime.minute = calender.component(.minute, from:datePicker.date)
        
        
        //通知に通知時間を設定
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        let request = UNNotificationRequest(identifier: "uuid", content: notificationContent, trigger: trigger)
        
        //通知を登録
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    @IBAction func weekClickButton(_ sender: UIButton) {
        
        //Create Date from picker selected value.
        func createDate(weekday: Int, hour: Int, minute: Int, year: Int)->Date{

            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.year = year
            components.weekday = weekday // sunday = 1 ... saturday = 7
            components.weekdayOrdinal = 10
            components.timeZone = .current

            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(from: components)!
        }

        //Schedule Notification with weekly bases.
        func scheduleNotification(at date: Date, body: String, titles:String) {

            let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

            let content = UNMutableNotificationContent()
            content.title = titles
            content.body = body
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "todoList"

            let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

            UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
            //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) {(error) in
                if let error = error {
                    print("Uh oh! We had an error: \(error)")
                }
            }
        }
        
    }
    
    //nilまたは空文字をチェックするメソッド
    //nilまたは空文字ならtrue,それ以外ならfalseを返す
    func isNullOrEmpty(text: String?) -> Bool{
        
        if text == nil || text == ""{
            return true
        }
        
        return false
        
    }

    //新しい日記を作成するメソッド
    func createNewTodo(title: String, body: String){
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //Realmに接続
        let realm = try! Realm()
        
        //新規日記作成
        let todo = Todo()
        
        //日記の項目をうめる
        todo.title = title
        todo.body = body
        todo.createdAt = Date()
        todo.id = 1
        
        //Realmに接続
        try! realm.write {
            realm.add(todo)
        }
        
        
        
        
    }
    
    //最大の日記IDを取得して返すメソッド
    func getMaxID() -> Int{
        
        //Realmに接続
        let realm = try! Realm()
        
        //現在あるIDの最大 + 1 を計算
        let id = (realm.objects(Todo.self).max(ofProperty: "id") as Int? ?? 0) + 1
        
        return id
        
    }
    
    //todo: 更新したいタスク
    func updateTask(newTitle: String, todo: Todo){
        //Realmに接続
        let realm = try! Realm()
        
        //タスクを更新する
        try! realm.write{
            todo.title = newTitle
        }
        
    }
    
    //タイトルと本文を受け取って日記を更新する
    func updateTodo(newTitle: String, newBody: String, todo: Todo){
        
        //Realmに接続
        let realm = try! Realm()
        
        //日記を更新する
        try! realm.write {
            todo.title = newTitle
            todo.body = newBody
        }
        
        
        
    }
    

}
