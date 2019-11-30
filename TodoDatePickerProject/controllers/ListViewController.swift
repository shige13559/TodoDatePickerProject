//
//  ListViewController.swift
//  TodoDatePickerProject
//
//  Created by 原田茂大 on 2019/12/01.
//  Copyright © 2019 geshi. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var todos: [Todo] = []{
        didSet{
            //値が書き換わったらテーブルを更新する
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //画面が表示される前に実行される(表示されるたび何度も)
    //日記の一覧を取得して、変数todosに設定する
    override func viewWillAppear(_ animated: Bool) {
        
        todos = getAllTodo()
        
    }
    
    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toInput", sender: nil)
        
    }
    
    
    //日記を全件取得するメソッド
    func getAllTodo() -> [Todo]{
        
        //Realmに接続
        let realm = try! Realm()
        
        //Realmからタスクの一覧を取得
        let todos: [Todo] = realm.objects(Todo.self).reversed()
        
        //日記を返す
        return todos
        
    }
    

    

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //取得したセルに表示する文字を設定
        let Todo = todos[indexPath.row]
        
        cell.textLabel?.text = Todo.title
        //完成したセルを返す
        return cell
    }
    //セルが選択された時に実行される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //クリックされたタスクを取得
        let value = todos[indexPath.row]
        
        //入力画面に移動
        performSegue(withIdentifier: "toInput", sender: value)
        
    }
    
    //画面遷移するときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //矢印の名前がtoInputの場合
        if segue.identifier == "toInput" {
            
            //InputViewControllerを取得
            let inputVC = segue.destination as! InputViewController
            
            //InputViewControllerに編集するタスクを設定
            inputVC.todo = sender as? Todo
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let realm = try! Realm()
            
            let todo = todos[indexPath.row]
            try! realm.write {
                realm.delete(todo)
            }
            
            todos.remove(at: indexPath.row)
        }
    }
    
    
}
