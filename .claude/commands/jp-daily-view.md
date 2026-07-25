---
description: 日本株ウォッチリスト（113銘柄）の株価を更新し、今日の相場観を主観/客観に分けてまとめる日次ルーティーン
---

# 日次相場観コメント / Daily Market View

CLAUDE.md のルール①〜④（日英併記・主観客観の明示・専門用語注釈・引用リンク化）に従い、今日の日本株市場がどう動くかをまとめる。
Following Rules ①-④ in CLAUDE.md (bilingual, subjective/objective split, term annotation, linkable citations), summarize how today's Japanese stock market is likely to move.

## 実行時点の日付 / Today's date

実行時点の日付を yyyy-MM-dd 形式で求め、これを {date} とする。
Compute today's date in yyyy-MM-dd format — this is {date}.

## ステップ / Steps

1. **ベースデータの確認 / Load baseline data**
   - `fundamentals/` 内で最新の `watchlist_fundamentals_*.md`（マスターDB）を探して読み込む。存在しない、または1ヶ月以上前の日付の場合は、コメント中で「データが古い可能性がある」旨を明記する（フル再調査はユーザーに別途確認してから行う。日次コマンド内では自動でフル再調査は行わない）。
   - [../決算日/決算発表予定一覧_2026.md](../../決算日/決算発表予定一覧_2026.md) およびマスターDBの「次回決算発表予定日」列を確認し、{date}から向こう1週間以内に決算発表が予定されているウォッチリスト銘柄を洗い出す。

2. **ダッシュボードの株価を更新 / Refresh the dashboard's DAILY object**
   [japan_equity_sector_map_v2.html](../japan_equity_sector_map_v2.html) 内の113銘柄（コード一覧は`<script>`内の`BASE`オブジェクトのキー）について、直近取引日の終値と前日比%を軽量調査する。114件近くあるため4バッチ程度に分けて並列エージェント（Yahoo!ファイナンス優先、kabutan.jpは403のため不使用、代替はirbank.net/nikkei.com/kabuyoho.ifis.co.jp）で取得し、`fundamentals/raw/pricechg_batchN.md`に保存したうえで、`<script>`内の`DAILY`オブジェクトを新しい`{コード:[株価,前日比%]}`の値に**すべて置き換え**、`AS_OF`の日付も更新する。
   - `BASE`オブジェクトやCSS・HTML本体（テーブル行・nav）は**触らない**（データ駆動設計のため、DAILYの差し替えだけで表・ミニチャート・セクターヒートマップが自動更新される）。
   - 決算発表・株式分割・上場廃止など個別銘柄の「事案」があった場合のみ、該当コードの`BASE`エントリ（p/per/pbr/cr/dec等）も更新する。
   - 更新後、Edgeヘッドレスでスクリーンショットを撮って表示崩れがないか確認する。

3. **当日の市況を調査 / Research today's market conditions**
   WebSearchで以下を調べる（出典URLを必ず控える）:
   - 前日までの日経平均・TOPIXの終値と当日の日経平均先物（CME/大阪取引所）の動き
   - 米国株市場（S&P500・NASDAQ・ダウ）の直近の終値・値動きとその主因
   - ドル円などの為替動向
   - 当日または直近の重要な経済指標・金融政策イベント（日銀・FRB等）
   - 地政学リスクなど、日本株全体に影響しうるニュース
   - 中国の景気・消費・当局の政策動向（インバウンド関連銘柄への影響が大きいため）

3.5. **世界情勢サマリーの更新 / Update the World Affairs cards**
   [japan_equity_sector_map_v2.html](../japan_equity_sector_map_v2.html) の `<script>` 内 `WORLD` オブジェクト（`japan`/`us`/`china`の3地域、必要なら追加可）を、ステップ3の調査結果に基づいて更新する。各地域について:
   - `summary`（日本語）/`en`（英語、簡潔に）: 当日の状況を2〜3文で
   - `score`: 日本株への影響度を **-2（強い逆風）〜+2（強い追い風）** で判定（主観的判断だが、根拠は`summary`に書いた客観情報に基づくこと）
   - `asOf`: 情報の基準日
   - `source`: 主要な出典URL（あれば）
   これにより、ページ上部の世界情勢カードの色（赤=追い風、緑=逆風）が自動更新される。旧「一週間の投資情報まとめ」プロジェクトで週次のみ行っていた世界情勢分析を、この日次カードとして統合したもの。

4. **ウォッチリストとの紐付け / Tie back to the watchlist**
   - ステップ1で洗い出した決算発表予定銘柄について、直近の材料・注目ポイントを一言添える。
   - ステップ2で更新した前日比%を踏まえ、ステップ3の市況ニュースがウォッチリストのどのセクター・銘柄に特に影響しそうかを、[japan_equity_sector_map_v2.html](../japan_equity_sector_map_v2.html) の11分類（ヒートマップで可視化済み）に照らして紐付ける。
   - 個別に大きなニュース（決算・M&A・規制・事故等）が出ている銘柄があれば、WebSearchで補足調査し追記する。
   - **ステップ3で拾った各ニュース項目について、関連するウォッチリスト銘柄（証券コード・銘柄名）を特定する。** 直接的な当事者銘柄だけでなく、同業種・サプライチェーン上の関連銘柄（例: 原油高→INPEX/ENEOS、米長期金利上昇→メガバンク3行、半導体安→東京エレクトロン等の半導体セクション）も拾う。関連銘柄がない場合は無理に紐付けず「関連銘柄なし」と明記する。

5. **主観/客観に分けてまとめる / Write the subjective/objective summary**
   以下の構成で、日本語・英語を併記して記述する:
   - **客観 (Objective)**: 前日までの市況データ、当日の先物・為替、決算発表予定、個別銘柄ニュース（すべて出典URL付き）。**各ニュース項目の末尾に「(関連銘柄: 8035 東京エレクトロン, 6857 アドバンテスト 等)」の形式で、ステップ4で特定した関連銘柄を必ず併記する。**
   - **主観 (Subjective)**: 上記を踏まえて、Claudeとして今日の相場がどう動きそうか、どのセクター・銘柄に注目すべきかの見解（推測であることを明示し、断定を避ける）
   - 専門用語（PER, PBR, 信用倍率, 先物, 板, 決算発表 等）が出た場合は簡潔な注釈を添える。

6. **保存 / Save**
   完成したコメントを `daily/{date}.md` として保存する。

7. **HTML/PDF化（ユーザーが希望する場合）/ HTML/PDF (on request)**
   ユーザーがHTMLやPDFでの閲覧を希望した場合、[templates](../../一週間の投資情報まとめ/templates/report_template.html)相当のスタイル（`.objective`/`.subjective`のボックス分け）を用いて `daily/{date}.html` を作成し、[scripts/Convert-DailyViewToPdf.ps1](../scripts/Convert-DailyViewToPdf.ps1) を実行して `daily/{date}_日次相場観.pdf` を生成する。

8. **ニュースログへの反映 / Update the news log**
   生成したコメントの中で、個別銘柄に固有の材料（決算・ガバナンス問題・上方修正・M&A等）が含まれる場合は、[japan_equity_sector_map_v2.html](../japan_equity_sector_map_v2.html) の `#newslog` セクションに新しい `.newslog-day` ブロックを**先頭に追加**し、`<span class="nl-code">コード</span>銘柄名: 内容` の形式で1〜2行程度にまとめて追記する。市況全体の話は `<span class="nl-macro">全体</span>` または `<span class="nl-macro">セクター</span>` タグを使うが、**ステップ4で特定した関連銘柄がある場合は、文末に「→関連: 8035 東京エレクトロン, 6857 アドバンテスト」のように併記する**。件数が多くなりすぎる場合は、株価インパクトの大きい材料に絞る。

## 完了報告 / Completion report

保存したファイルパスとともに、主観/客観に分けた本文をそのままユーザーに提示する。
Present the saved file path along with the full subjective/objective text to the user.

自動投稿・自動売買は一切行わない。
No auto-posting or auto-trading is performed.
