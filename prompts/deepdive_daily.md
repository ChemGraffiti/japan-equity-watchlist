# DEEPDIVE（本日の日本株総合分析）日次自動更新 手順書

クラウドルーティーン「日本株ウォッチリスト DEEPDIVE更新（07:00）」が毎回この手順書を読んで実行する。
手順を変えたいときはこのファイルを編集してpushすれば、次回実行から反映される（トリガー側のプロンプトは変更不要）。

## 前提
- 対象: `japan_equity_sector_map_v2.html` の `const DEEPDIVE = {...};`（1行のJSON）だけを書き換える。他のJSオブジェクト（`DAILY`/`WORLD`/`PICKS`/`EVENTS`/`AS_OF` 等）は**一切変更しない**（それらはGemini調査パイプラインの担当）。
- 調査は **自分のWebSearch / WebFetch** で行う。Gemini APIは使わない（課金停止中でもこのルーティーンは動く設計）。
- WebSearchは合計 **12回以内**、WebFetchは **8回以内**。予算を使い切りそうなら、確認できた範囲だけで作り、未確認の項目は `"—"` にする。
- kabutan.jp / minkabu.jp / Google Finance はWebFetchで403・非対応になりやすい。個別銘柄の終値・PER・PBR・年初来高値/安値は `https://finance.yahoo.co.jp/quote/{code}.T` が取りやすい。
- **数値を創作しない。** 出典で確認できない数値は `"—"`。主観（予想・解釈）には文末に「(推定)」を付ける。

## ステップ1: 現状確認
1. `git pull --rebase origin main` で最新化。
2. 現在の `DEEPDIVE.asOf` を確認。日付が今日（JST）と同じなら、既に今日分は作成済みなので何もせず終了。
3. 今日が東証の休場日（土日祝・年末年始）なら作成せず終了。

## ステップ2: 調査（客観データ）
直近の取引日（通常は前営業日）について、以下を確認する。
- 日経平均・TOPIX の終値と前日比（値・%）
- ドル円、NYダウ（前日の米国市場の終値・前日比）、米10年債利回り、WTI原油
- 前日の東京市場の主な値動き要因（上昇・下落の理由）
- 今後5営業日の主要イベント（日銀会合、FOMC、主要経済指標、ウォッチリスト銘柄や米大手の決算）。ダッシュボードの `const EVENTS` も参考にしてよい（ただし日付は自分で検証）
- ピックアップ3銘柄（下記）の終値・前日比・PER(予想)・PBR(実績)・年初来高値/安値

### ピックアップ銘柄の選び方
ウォッチリスト（`const DAILY` に含まれるコード）の中から、**今後5営業日以内に決算やイベントがある銘柄、または直近の値動きが大きく材料がはっきりしている銘柄**を3つ選ぶ。前日と同じ3銘柄を機械的に続けない（材料が続いている場合は継続可）。

## ステップ3: DEEPDIVE を作る
以下のスキーマを**厳守**する（キー名・型を変えない。`renderDeepDive()` がこの形を前提にしている）。

```json
{
  "asOf": "YYYY-MM-DD HH:MM",          // 実行時刻(JST)
  "intro": "相場の全体像 3〜5文。主観部分は(推定)",
  "stats": [ {"label":"日経平均(MM/DD)","val":"62,693.16","unit":"円","chg":"-214.68 (-0.34%)","dir":"down"}, ... 6件 ],
                                        // 日経平均/TOPIX/ドル円/NYダウ/米10年債利回り/WTI原油。dirは"up"|"down"|""。前日比不明ならchg:""
  "factorsBull": [ {"name":"…","desc":"…","stars":1-5}, ... 2〜4件 ],
  "factorsBear": [ {"name":"…","desc":"…","stars":1-5}, ... 2〜4件 ],
  "events": [ {"title":"イベント名 (MM/DD)","demand":"real"|"thin","themes":["関連テーマ1","2","3"],"note":"…"}, ... 3〜5件 ],
                                        // demand: real=受注・業績など実需の裏付けあり / thin=思惑・連想が先行
  "picks": [ {"code":"6857","name":"…","price":"32,340","chg":"-0.09%","dir":"down","per":"35.5","pbr":"22.5",
              "support":"…","resistance":"…","high":"…","low":"…","phase":"調整局面","subj":"主観コメント(推定)"}, ... 3件 ],
  "actionPlan": [ {"term":"短期","text":"…"}, {"term":"中期","text":"…"}, {"term":"長期","text":"…"} ],
  "conclusion": "結論 2〜3文",
  "risks": ["リスク1", "リスク2", "リスク3"],
  "beginner": "初心者向けの超簡単まとめ（専門用語を使わない）",
  "sources": [ {"label":"出典名","url":"https://..."}, ... 実際に参照したもののみ ],
  "techNote": "株価・前日比はMM/DD終値、PER(予想)/PBR(実績)・直近高値/安値(年初来)は出典(MM/DD時点)。支持線は心理的節目、抵抗線は直近の終値ベースの戻り目安で、いずれも機械的な目安です。"
}
```

- `high`/`low` は年初来高値/安値（出典の値）。`support` は直近値より下のキリのいい節目、`resistance` は5営業日前の終値など直近の戻り目安。どちらも根拠が取れなければ `"—"`。
- 客観（数値・事実）と主観（解釈・予想）を混ぜない。`picks[].subj`・`intro`・`factors` の見立て部分・`conclusion` は主観なので「(推定)」を付ける。
- 文字列中に `"` を使わない（JSONが壊れる）。強調は「」を使う。

## ステップ4: 書き込みと検証
1. `const DEEPDIVE = ` で始まる1行を、`const DEEPDIVE = <JSON>;` で置き換える（Pythonの `json.dumps(obj, ensure_ascii=False)` を使い、手書きでJSONを組まない）。
2. `node -e` で該当行を `eval` してパースできることを確認（nodeが無ければPythonの `json.loads` で確認）。
3. 置き換え後のファイルで `const DEEPDIVE` がちょうど1回だけ存在すること、他の行に差分が無いこと（`git diff --stat` が1行の変更）を確認。

## ステップ5: コミット・push
- `git add japan_equity_sector_map_v2.html` → `git commit -m "DEEPDIVE daily update: {YYYY-MM-DD HH:MM} (picks: {code1}/{code2}/{code3})"`
- `git pull --rebase origin main` → `git push origin main`。競合したら（Geminiパイプラインと同時更新の可能性）、`DEEPDIVE` の行だけ自分の版を採用し、他は相手の版を採用して解決する。
- `daily/` への記録は不要（コミットメッセージで十分）。

## 完了報告
asOf、ピックアップ3銘柄、WebSearch/WebFetchの使用回数、「—」にした項目、コミットハッシュを報告する。

## 注意事項
- 自動売買・SNS投稿は一切行わない。
- APIキー等の秘密情報をリポジトリに書かない。
