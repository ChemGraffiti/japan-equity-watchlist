# CLAUDE.md

## プロジェクト概要 / Project Overview

このプロジェクト「日本銘柄分類」は、ユーザーが保有・監視する日本株ウォッチリスト（[japan_equity_sector_map_v2.html](japan_equity_sector_map_v2.html)、113銘柄・11大分類・41小分類）について、
①各銘柄のファンダメンタルデータ（株価・PER・PBR・信用倍率・次回決算日・IR等）を継続的に記録し、
②その記録と当日のニュース・世界情勢を踏まえて「今日の相場がどう動くか」を主観・客観に分けてコメントできる状態を維持することを目的とする。

This project, "Japan Equity Classification," maintains the user's Japanese stock watchlist ([japan_equity_sector_map_v2.html](japan_equity_sector_map_v2.html), 113 tickers across 11 sectors / 41 sub-sectors). It (1) continuously records each ticker's fundamentals (price, PER, PBR, margin/credit ratio, next earnings date, IR) and (2) keeps Claude ready to comment — split into subjective and objective — on how the market is likely to move each day, based on that record plus the day's news and world affairs.

## 関連プロジェクト / Related Projects

- [一週間の投資情報まとめ](../一週間の投資情報まとめ/) — 週次（毎週日曜）の日本株市場戦略レポート・X投稿ドラフト作成プロジェクト。本プロジェクトのウォッチリストは、週次レポートの銘柄ピックアップの土台としても使う。
- [決算日](../決算日/決算発表予定一覧_2026.md) — 決算発表予定日調査の既存データ（2026-06-21時点、106社）。本プロジェクトの決算日調査のベースラインとして参照する。kabutan.jp（株探）は403エラーで直接アクセス不可、IFIS株予報(kabuyoho.ifis.co.jp)・各社公式IR・Yahoo!ファイナンス・irbank.net・みんかぶ等を併用する。
- [投資対象全面可視化](../投資対象全面可視化/) — JP+US 18テーマ・131銘柄の先行調査プロジェクト。ファンダメンタル調査のバッチ分割・エージェント並列実行・出典URL明記という調査フォーマットの前例。

## ユーザープロフィール / User Profile

- ユーザーは理論家な情報研究者である。論理的な根拠・データに基づいた分析を重視する。
- The user is a theoretical, research-oriented analyst. They value logic-based, data-driven analysis.

## 必ず守るルール / Mandatory Rules

一週間の投資情報まとめプロジェクトと同じ方針を踏襲する。

### ① 日英併記 / Bilingual Responses
すべての回答は日本語と英語を併記すること。
All responses must be written in both Japanese and English.

### ② 主観と客観の明示 / Distinguish Subjective vs. Objective
- **主観 (Subjective)**: Claude自身の考え・予想・解釈
- **客観 (Objective)**: 参照データ・ロジック・出典に基づく事実
When answering, clearly separate Claude's own opinions/predictions from facts based on data/sources.

### ③ 専門用語への注釈 / Annotate Technical Terms
PER・PBR・信用倍率などの専門用語が登場した場合は、必ず簡潔な注釈を付けること。
Whenever a technical term appears, always provide a brief annotation.

### ④ 引用文献のリンク化 / Linkable Citations
引用するデータ・記事・文献は、必ずリンクまたは参照可能な形で明示すること。
Any cited data, articles, or literature must always be presented with a link or in a verifiable/traceable form.

## データ構成 / Data Layout

- `japan_equity_sector_map_v2.html` — **ライブダッシュボード本体**。113銘柄の分類マップに加え、各行に株価/PER/PBR/信用倍率/次回決算日をミニバーチャート（前日比%バッジ付き、赤=上昇・緑=下落）で表示し、11業種タブは業種平均前日比のヒートマップで自動着色。ページ上部には🌍**世界情勢サマリー**（日本・米国・中国・韓国、日本株への影響度を赤=追い風/緑=逆風で色分け）、11業種セクションの後には🇺🇸**米国対応銘柄**セクション（113銘柄それぞれの競合/顧客/供給元/投資家関係にあたる米国上場銘柄1社とファンダメンタル）、下部には📰デイリーニュースログ（`#newslog`セクション）を持つ。
  - **2026-07-25にデータ駆動方式へ全面改修済み**。表の見た目はHTMLに直書きせず、ファイル末尾の`<script>`内にあるJSオブジェクトから毎回自動生成される（`renderFundCells()`/`renderHeatmap()`/`renderWorld()`）。**この設計のおかげで日次更新はJSオブジェクトの中身を差し替えるだけで済み、HTML本体（テーブル行・nav等）は一切触らなくてよい。**
    - `BASE`: 銘柄コード→{基準株価p, PER, PBR, 信用倍率cr, 決算文言dec, 大分類番号s, ...}。決算発表・株式分割など「事案（イベント）」があった銘柄のみ、該当コードのオブジェクトを更新する（他の銘柄は触らない）。
    - `DAILY`: 銘柄コード→[当日株価, 前日比%] のペア。**日次更新で書き換えるのはここだけ**。PER/PBRはBASE値×(DAILY株価/BASE株価)で自動換算され、11業種タブの色もDAILYの前日比%から自動計算される。
    - `WORLD`: 地域キー（`japan`/`us`/`china`/`korea`、必要に応じて追加可）→{summary(日本語), en(英語), score(-2〜+2で日本株への影響度), asOf, source}。旧「一週間の投資情報まとめ」プロジェクトで**週次のみ**行っていた世界情勢分析を、この日次カードとして本プロジェクトに統合したもの。日次更新のたびに`summary`/`en`/`score`/`asOf`を書き換える。`korea`は半導体セクター（ウォッチリスト最大38銘柄）への連れ安・連れ高の影響が大きいため常設。
  - `USBASE`/`US_PRICE`（2026-07-26追加）: 113銘柄それぞれに対応する米国上場銘柄（競合/顧客/供給元/投資家関係のいずれかで最も投資分析上意味のある1社、`#us`セクションに表示）。キーはJPコード。`USBASE[code]`は{ティッカーt, 社名n, 基準PER/PBR, 決算日dec, 関係性rel, 選定理由why}、`p`（基準株価USD）は起動時に`US_PRICE`から自動セットされる。**日次更新で書き換えるのは`US_PRICE`のみ**（PER/PBRはJPのBASE/DAILYと同じ`ratio = US_PRICE/USBASE.p`方式で自動換算）。関係性・選定理由（`rel`/`why`）はイベント発生時のみ更新。全113社のtickerと関係性の一覧は本ファイルの`USBASE`定義を参照。
- `fundamentals/raw/batchNN.md` — 初回フル調査（バッチ調査エージェント）の生データ
- `fundamentals/raw/pricechg_batchN.md` — 株価・前日比%のみを取得する軽量バッチ調査の生データ（日次更新用）
- `fundamentals/watchlist_fundamentals_{date}.md` — フル調査を統合したマスターデータベース（詳細出典URL付き）。BASEオブジェクトの一次情報源。
- `daily/{date}.md` / `daily/{date}.html` / `daily/{date}_日次相場観.pdf` — `/jp-daily-view` コマンドで生成した日次の主観/客観市況コメント
- `.claude/commands/jp-daily-view.md` — 日次ルーティーン用スラッシュコマンド定義
- `scripts/Convert-DailyViewToPdf.ps1` — 日次コメントHTML→PDF変換スクリプト（PS1ファイルはUTF-8 BOM必須、日本語ファイル名が文字化けする）

## ファンダメンタルDBの更新方針 / Fundamentals DB Update Policy

- **日次更新（毎日行う想定）**: 113銘柄の株価・前日比%のみを軽量エージェント（4バッチ程度、Yahoo!ファイナンス優先・kabutan.jpは使用不可）で取得し、`japan_equity_sector_map_v2.html`末尾の`<script>`内`DAILY`オブジェクトを新しい値に置き換える（`AS_OF`日付も更新）。PER/PBR再計算とヒートマップ再着色はJSが自動で行うため、HTML本体・CSS・BASEオブジェクトは触らない。あわせて`US_PRICE`（113社の対応米国銘柄の株価、ticker→USD）も同様に軽量取得して置き換える（`USBASE`のPER/PBR/決算日/関係性は触らない。stockanalysis.com優先）。
- **イベント更新（決算発表・株式分割・上場廃止など、随時）**: 該当銘柄1件だけ`BASE`オブジェクトのそのコードのエントリを更新する（基準株価p・PER・PBR・信用倍率・決算文言dec等）。他の112銘柄には触れない。あわせて`#newslog`セクションに1行追記する。
- **フル更新（全113銘柄の株価・PER・PBR・信用倍率等の再調査）**: 月1回程度を目安に、`fundamentals/watchlist_fundamentals_{date}.md`を再作成し、その内容で`BASE`オブジェクト全体を更新する。
- 次回決算日が近い（1週間以内）銘柄は、日次コメントで優先的に言及する。

## 自動化について / On Automation

ローカルPCのCronはPCがスリープ中は発火しないため採用しない（[一週間の投資情報まとめ](../一週間の投資情報まとめ/CLAUDE.md)と同じ理由）。代わりに**2026-07-25、クラウド側のスケジュール実行（`schedule`スキル／`RemoteTrigger`）を設定済み**。クラウドエージェントはローカルPCにアクセスできないため、このプロジェクトはGitHubリポジトリ経由で運用する。

- **GitHubリポジトリ**: https://github.com/ChemGraffiti/japan-equity-watchlist （**2026-07-25にPublicへ変更**。理由: タブレット/スマホのOneDriveアプリのプレビューはJavaScriptを実行せず、数値・色が表示されないため、GitHub Pagesでブラウザから直接閲覧できるようにした）。ローカルの変更は都度 `git push origin main` してリポジトリに反映する。クラウド側の日次更新もこのリポジトリにpushされるため、ローカルで最新を見たい場合は `git pull` する。
- **GitHub Pages（スマホ・タブレット閲覧用）**: https://chemgraffiti.github.io/japan-equity-watchlist/ （`main`ブランチ・ルートから配信。`index.html`は`japan_equity_sector_map_v2.html`へ即時リダイレクトするだけの薄いファイル）。クラウドルーティーンが`git push`するたびに数分でこのURLにも自動反映される。**リポジトリがPublicのため、ここに機密情報（パスワード・APIキー等）を絶対にコミットしないこと。**
- **ルーティーンID**: `trig_01MHvJpzmYjM1hoS8RqtCuKS`（名前:「日本株ウォッチリスト 日次更新」）。管理・停止は https://claude.ai/code/routines から。
- **実行タイミング**: 毎週月〜金曜 JST 6:00開始（cron: `0 21 * * 0-4` UTC）。7:00完了を目安に1時間のバッファを確保。
- **毎朝の処理内容**（プロンプトはルーティーン本体に記載。ローカルの`.claude/commands/jp-daily-view.md`と同等の内容をクラウド実行版として保持）:
  1. 113銘柄の株価前日比を調査し`DAILY`を更新。あわせて対応米国銘柄113社の株価も調査し`US_PRICE`を更新
  2. 市況調査（日本・米国・中国・韓国の世界情勢を含む）＋ニュースごとに関連するウォッチリスト銘柄を特定
  3. `WORLD`オブジェクトを更新（世界情勢サマリーカード）
  4. 主観/客観コメントを`daily/{date}.md`に生成（関連銘柄を併記）
  5. `#newslog`に個別材料を追記
  6. GitHubにコミット・push
  7. Gmail下書きを作成（**自動送信ではなく下書きのみ**、Gmail連携にsend機能がないため）
  8. Googleドライブの「日本株ウォッチリスト」フォルダに日次コメント・ダッシュボードHTMLを保存
- ルーティーン本体を更新する際は、ローカルの`.claude/commands/jp-daily-view.md`を先に直してから、同じ変更内容を`RemoteTrigger`の`update`でルーティーンのプロンプトにも反映すること（2箇所が乖離しないように）。

Local Cron is not used since it doesn't fire while the PC is asleep. Instead, a **cloud-scheduled routine** (via the `schedule` skill / `RemoteTrigger`) was set up on 2026-07-25. Since cloud agents can't reach the local PC, this project is operated through a GitHub repository (see above) that the cloud routine clones, updates, and pushes to every weekday morning (JST 6:00, targeting 7:00 completion). It also drafts a Gmail summary (draft only — the connector has no send capability) and saves snapshots to Google Drive.

## 実行方法 / How to Run

- 初回・フル更新: ユーザーの指示に応じて、113銘柄を約12銘柄ずつ10バッチに分割し、並列エージェント（Opus使用可）で株価・PER・PBR・信用倍率・次回決算日・その他ファンダメンタル・IR・関連ニュースを調査し、`fundamentals/watchlist_fundamentals_{date}.md` に統合したうえで、その内容で`japan_equity_sector_map_v2.html`の`BASE`オブジェクトを更新する。
- 日次（ローカル手動）: `/jp-daily-view` を実行すると、①113銘柄の株価・前日比%を軽量バッチ調査で取得して`DAILY`オブジェクトを差し替え、②世界情勢を調査して`WORLD`オブジェクトを更新、③マスターDBと当日のニュースを踏まえた主観/客観コメント（関連銘柄併記）を`daily/{date}.md`に生成、④個別材料があれば`#newslog`に追記する。
- 日次（クラウド自動）: 上記「自動化について」のクラウドルーティーンが平日毎朝自動実行する。ローカルで最新を見るには`git pull`が必要。
- 自動投稿・自動売買は一切行わない。
