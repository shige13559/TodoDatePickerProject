//
//  InputViewController.swift
//  TodoDatePickerProject
//
//  Created by 原田茂大 on 2019/12/01.
//  Copyright © 2019 geshi. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
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
