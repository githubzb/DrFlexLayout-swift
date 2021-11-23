//
//  FlexTableViewController2.swift
//  DrFlexLayoutDemo
//
//  Created by DHY on 2021/11/22.
//

import UIKit
import DrFlexLayout

class FlexTableViewController2: UIViewController {
    
    var table: DrFlexTableView { view as! DrFlexTableView }
    
    override func loadView() {
        view = DrFlexTableView(style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hexColor("#F3F3F3")
        
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: 0, height: 0.001)
        table.tableHeaderView = header
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加载", style: .plain, target: self, action: #selector(loadNews))
    }
    
    @objc func loadNews() {
        table.reload() // 清空视图
        
        table.appendGroup(DRFlexTableGroup(header: {
            let v = UIView()
            v.dr_flex.paddingHorizontal(15)
                .addItem()
                .backgroundColor(.orange)
                .height(30)
                .justifyContent(.center)
                .addItem(UILabel()).define { flex in
                    let lb = flex.view as? UILabel
                    lb?.text = "国内新闻"
                    lb?.textColor = .white
                    lb?.font = .systemFont(ofSize: 14, weight: .regular)
                }
            return v
        }(), footer: nil, cellList: {
            [
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "不只有中印和台海！中国可能面临“三线作战”的险境", subTitle: "前几天我们探讨了中国现在面临的现实困境，中国现在是可以说是典型的“两线作战”，东边有台湾问题，西边则有中印边境问题，而且就历史经验来看，这两个问题大概率还得依靠武力解决。但是话题说完后")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "微思政 | 白山黑水间，血性忆抗联", subTitle: "在东北茫茫的林海雪原深处，有一棵树上刻着一句让人泪目的标语：抗联从此过，子孙不断头。这句话仿佛打开时空之门，让人们看到东北抗联队伍趟着过膝的大雪，辗转山林")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "不只有中印和台海！中国可能面临“三线作战”的险境", subTitle: "前几天我们探讨了中国现在面临的现实困境，中国现在是可以说是典型的“两线作战”，东边有台湾问题，西边则有中印边境问题，而且就历史经验来看，这两个问题大概率还得依靠武力解决。但是话题说完后")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "微思政 | 白山黑水间，血性忆抗联", subTitle: "在东北茫茫的林海雪原深处，有一棵树上刻着一句让人泪目的标语：抗联从此过，子孙不断头。这句话仿佛打开时空之门，让人们看到东北抗联队伍趟着过膝的大雪，辗转山林")),
            ]
        }()))
        
        table.appendGroup(DRFlexTableGroup(header: {
            let v = UIView()
            v.dr_flex.paddingHorizontal(15)
                .addItem()
                .backgroundColor(.orange)
                .height(30)
                .justifyContent(.center)
                .addItem(UILabel()).define { flex in
                    let lb = flex.view as? UILabel
                    lb?.text = "国外新闻"
                    lb?.textColor = .white
                    lb?.font = .systemFont(ofSize: 14, weight: .regular)
                }
            return v
        }(), footer: nil, cellList: {
            [
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "国际新闻早报", subTitle: "联合国秘书长古特雷斯21日就世界道路交通事故受害者纪念日发表致辞，呼吁国际社会共同努力，使世界各地的道路更加安全")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "立陶宛声称台机构不具“外交地位”", subTitle: "还在狡辩！立陶宛外交部副部长声称：台当局在立所设机构不具“外交地位”")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "这个周末，10万民众涌上澳大利亚街头；美国机场陷入混乱", subTitle: "眼下，世界局势风云变幻，新冠病毒和能源危机，时刻牵动着国际社会的神经")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "11月21日，沙特炼油厂被炸，美澳多国陷入混乱，伊朗波斯湾再出手", subTitle: "世界局势风云突变，世界的变量逐渐增加，突发事件明显增多！美国主动承诺不会放弃中东，将会在中东保留部分军事力量，确保美国在中东的控制能力。可是美军做出的承诺，并不能挡住中东意外事件的发生。第一件事")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "这个周末，10万民众涌上澳大利亚街头；美国机场陷入混乱", subTitle: "眼下，世界局势风云变幻，新冠病毒和能源危机，时刻牵动着国际社会的神经")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "这个周末，10万民众涌上澳大利亚街头；美国机场陷入混乱", subTitle: "眼下，世界局势风云变幻，新冠病毒和能源危机，时刻牵动着国际社会的神经")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "这个周末，10万民众涌上澳大利亚街头；美国机场陷入混乱", subTitle: "眼下，世界局势风云变幻，新冠病毒和能源危机，时刻牵动着国际社会的神经")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "立陶宛声称台机构不具“外交地位”", subTitle: "还在狡辩！立陶宛外交部副部长声称：台当局在立所设机构不具“外交地位”")),
                NewsItemCell(model: NewsItem(imgColor: .orange, title: "立陶宛声称台机构不具“外交地位”", subTitle: "还在狡辩！立陶宛外交部副部长声称：台当局在立所设机构不具“外交地位”")),
            ]
        }()))
        
        table.refresh() // 这里需要手动刷新
    }
    
    deinit{
        print("----table2 deinit")
    }
    
}
