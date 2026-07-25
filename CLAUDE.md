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

- `japan_equity_sector_map_v2.html` — **ライブダッシュボード本体**。113銘柄の分類マップに加え、各行に株価/PER/PBR/信用倍率/次回決算日をミニバーチャート（前日比%バッジ付き、赤=上昇・緑=下落）で表示し、11業種タブは業種平均前日比のヒートマップで自動着色。ページ下部に📰デイリーニュースログ（`#newslog`セクション）を持つ。
  - **2026-07-25にデータ駆動方式へ全面改修済み**。表の見た目はHTMLに直書きせず、ファイル末尾の`<script>`内にある2つのJSオブジェクトから毎回自動生成される（`renderFundCells()`/`renderHeatmap()`）。**この設計のおかげで日次更新はJSオブジェクトの中身を差し替えるだけで済み、HTML本体（テーブル行・nav等）は一切触らなくてよい。**
    - `BASE`: 銘柄コード→{基準株価p, PER, PBR, 信用倍率cr, 決算文言dec, 大分類番号s, ...}。決算発表・株式分割など「事案（イベント）」があった銘柄のみ、該当コードのオブジェクトを更新する（他の銘柄は触らない）。
    - `DAILY`: 銘柄コード→[当日株価, 前日比%] のペア。**日次更新で書き換えるのはここだけ**。PER/PBRはBASE値×(DAILY株価/BASE株価)で自動換算され、11業種タブの色もDAILYの前日比%から自動計算される。
- `fundamentals/raw/batchNN.md` — 初回フル調査（バッチ調査エージェント）の生データ
- `fundamentals/raw/pricechg_batchN.md` — 株価・前日比%のみを取得する軽量バッチ調査の生データ（日次更新用）
- `fundamentals/watchlist_fundamentals_{date}.md` — フル調査を統合したマスターデータベース（詳細出典URL付き）。BASEオブジェクトの一次情報源。
- `daily/{date}.md` / `daily/{date}.html` / `daily/{date}_日次相場観.pdf` — `/jp-daily-view` コマンドで生成した日次の主観/客観市況コメント
- `.claude/commands/jp-daily-view.md` — 日次ルーティーン用スラッシュコマンド定義
- `scripts/Convert-DailyViewToPdf.ps1` — 日次コメントHTML→PDF変換スクリプト（PS1ファイルはUTF-8 BOM必須、日本語ファイル名が文字化けする）

## ファンダメンタルDBの更新方針 / Fundamentals DB Update Policy

- **日次更新（毎日行う想定）**: 113銘柄の株価・前日比%のみを軽量エージェント（4バッチ程度、Yahoo!ファイナンス優先・kabutan.jpは使用不可）で取得し、`japan_equity_sector_map_v2.html`末尾の`<script>`内`DAILY`オブジェクトを新しい値に置き換える（`AS_OF`日付も更新）。PER/PBR再計算とヒートマップ再着色はJSが自動で行うため、HTML本体・CSS・BASEオブジェクトは触らない。
- **イベント更新（決算発表・株式分割・上場廃止など、随時）**: 該当銘柄1件だけ`BASE`オブジェクトのそのコードのエントリを更新する（基準株価p・PER・PBR・信用倍率・決算文言dec等）。他の112銘柄には触れない。あわせて`#newslog`セクションに1行追記する。
- **フル更新（全113銘柄の株価・PER・PBR・信用倍率等の再調査）**: 月1回程度を目安に、`fundamentals/watchlist_fundamentals_{date}.md`を再作成し、その内容で`BASE`オブジェクト全体を更新する。
- 次回決算日が近い（1週間以内）銘柄は、日次コメントで優先的に言及する。

## 自動化について / On Automation

CronによるPC起動中のみの定時実行は、PCがスリープ中は発火しないため採用しない（[一週間の投資情報まとめ](../一週間の投資情報まとめ/CLAUDE.md)と同じ理由）。ユーザーが任意のタイミングで `/jp-daily-view` を実行する方式とする。

Time-based Cron automation is not used, since it doesn't fire while the PC is asleep (same reasoning as the weekly report project). The user runs `/jp-daily-view` on demand instead.

## 実行方法 / How to Run

- 初回・フル更新: ユーザーの指示に応じて、113銘柄を約12銘柄ずつ10バッチに分割し、並列エージェント（Opus使用可）で株価・PER・PBR・信用倍率・次回決算日・その他ファンダメンタル・IR・関連ニュースを調査し、`fundamentals/watchlist_fundamentals_{date}.md` に統合したうえで、その内容で`japan_equity_sector_map_v2.html`の`BASE`オブジェクトを更新する。
- 日次: `/jp-daily-view` を実行すると、①113銘柄の株価・前日比%を軽量バッチ調査で取得して`DAILY`オブジェクトを差し替え（ダッシュボードのミニチャート・ヒートマップが自動更新）、②マスターDBと当日のニュースを踏まえた主観/客観コメントを`daily/{date}.md`に生成、③個別材料があれば`#newslog`に追記する。
- 自動投稿・自動売買は一切行わない。
