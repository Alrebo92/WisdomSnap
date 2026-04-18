import Foundation

/// ローカルに保持する提案データベース
/// テーマ × タイプ ごとに提案候補を持つ
struct LocalSuggestionDatabase {

    struct Entry {
        let content: String
        let type: SuggestionType
        let category: String
        let relatedKeywords: [String]  // マッチング精度向上用
    }

    static let entries: [Entry] = [

        // MARK: - マインドセット
        Entry(content: "失敗は成功への最短ルートだ。転んだ回数より、立ち上がった回数を数えよう。",
              type: .quote, category: "マインドセット",
              relatedKeywords: ["失敗", "成功", "挑戦", "行動"]),
        Entry(content: "成長は快適ゾーンの外にある。今日、少しだけ不快なことに挑んでみよう。",
              type: .action, category: "マインドセット",
              relatedKeywords: ["成長", "挑戦", "快適", "変化"]),
        Entry(content: "自分に期待することをやめた瞬間、成長も止まる。",
              type: .quote, category: "マインドセット",
              relatedKeywords: ["期待", "成長", "可能性", "自己"]),
        Entry(content: "毎朝「今日の自分は昨日より少し良くなれる」と声に出す。",
              type: .habit, category: "マインドセット",
              relatedKeywords: ["朝", "習慣", "成長", "マインド"]),

        // MARK: - 習慣
        Entry(content: "習慣は第二の天性だ。小さな行動を毎日積み重ねることが人生を変える。",
              type: .quote, category: "習慣",
              relatedKeywords: ["習慣", "継続", "毎日", "積み重ね"]),
        Entry(content: "新しい習慣は既存の習慣に紐付けて始める。「〇〇した後に△△する」と決める。",
              type: .habit, category: "習慣",
              relatedKeywords: ["習慣", "ルーティン", "毎日", "続ける"]),
        Entry(content: "今日から1つだけ、寝る前の5分をその日の振り返りに使ってみよう。",
              type: .action, category: "習慣",
              relatedKeywords: ["振り返り", "夜", "日記", "継続"]),
        Entry(content: "21日間続けると習慣になると言われる。まず3日間だけ続けてみよう。",
              type: .habit, category: "習慣",
              relatedKeywords: ["21日", "習慣", "継続", "3日"]),

        // MARK: - 健康
        Entry(content: "健康は最大の投資だ。体を大切にすることで、全ての目標に近づける。",
              type: .quote, category: "健康",
              relatedKeywords: ["健康", "体", "運動", "睡眠"]),
        Entry(content: "毎日10分の散歩を始めよう。頭が冴え、アイデアが生まれやすくなる。",
              type: .habit, category: "健康",
              relatedKeywords: ["散歩", "運動", "歩く", "健康"]),
        Entry(content: "今日、水を2リットル飲むことだけに集中してみよう。",
              type: .action, category: "健康",
              relatedKeywords: ["水", "水分", "健康", "体"]),
        Entry(content: "睡眠は生産性の土台。就寝1時間前のスマホをやめてみよう。",
              type: .habit, category: "健康",
              relatedKeywords: ["睡眠", "スマホ", "休息", "生産性"]),

        // MARK: - 生産性
        Entry(content: "完璧を求めるより、まず動き出すことが最重要だ。",
              type: .quote, category: "生産性",
              relatedKeywords: ["完璧", "行動", "先延ばし", "スタート"]),
        Entry(content: "タスクは「2分以内にできるものはすぐやる」というルールで動こう。",
              type: .habit, category: "生産性",
              relatedKeywords: ["タスク", "2分", "すぐやる", "GTD"]),
        Entry(content: "毎朝、今日の最重要タスクを1つだけ決めてから作業を始める。",
              type: .habit, category: "生産性",
              relatedKeywords: ["朝", "タスク", "優先", "集中"]),
        Entry(content: "集中力が続かないなら25分集中+5分休憩のポモドーロを試してみよう。",
              type: .action, category: "生産性",
              relatedKeywords: ["集中", "ポモドーロ", "25分", "休憩"]),

        // MARK: - 学習・読書
        Entry(content: "読んだ本の知識は行動に移して初めて価値が生まれる。",
              type: .quote, category: "学習",
              relatedKeywords: ["読書", "知識", "行動", "学習"]),
        Entry(content: "本を読んだら「3つの気づき」と「1つのアクション」を書き出す習慣を作ろう。",
              type: .habit, category: "学習",
              relatedKeywords: ["読書", "アウトプット", "ノート", "気づき"]),
        Entry(content: "今日読んだ/見た内容を誰かに説明してみよう。理解度が格段に上がる。",
              type: .action, category: "学習",
              relatedKeywords: ["アウトプット", "説明", "理解", "学習"]),

        // MARK: - 人間関係
        Entry(content: "人を変えようとするより、自分が変わる方が100倍速い。",
              type: .quote, category: "人間関係",
              relatedKeywords: ["人間関係", "変化", "自分", "他人"]),
        Entry(content: "今日、大切な人に感謝の言葉を1つ伝えてみよう。",
              type: .action, category: "人間関係",
              relatedKeywords: ["感謝", "言葉", "人間関係", "コミュニケーション"]),

        // MARK: - キャリア・成功
        Entry(content: "成功者は機会を待たず、機会を作る。",
              type: .quote, category: "キャリア",
              relatedKeywords: ["成功", "機会", "キャリア", "行動"]),
        Entry(content: "週に1度、自分のキャリアの進捗を振り返る時間を作ろう。",
              type: .habit, category: "キャリア",
              relatedKeywords: ["キャリア", "振り返り", "目標", "成長"]),

        // MARK: - お金
        Entry(content: "お金の管理は自己管理の縮図だ。小さな支出から見直してみよう。",
              type: .quote, category: "お金",
              relatedKeywords: ["お金", "節約", "投資", "管理"]),
        Entry(content: "毎月の支出を3つのカテゴリに分けて記録する習慣を始めよう。",
              type: .habit, category: "お金",
              relatedKeywords: ["家計", "記録", "支出", "管理"]),

        // MARK: - 創造性
        Entry(content: "アイデアは組み合わせから生まれる。異なる分野のインプットを増やそう。",
              type: .quote, category: "創造性",
              relatedKeywords: ["アイデア", "創造性", "インプット", "組み合わせ"]),
        Entry(content: "毎日1つ、気になったことをメモする習慣がアイデアの泉になる。",
              type: .habit, category: "創造性",
              relatedKeywords: ["メモ", "アイデア", "気づき", "創造"]),
    ]
}
