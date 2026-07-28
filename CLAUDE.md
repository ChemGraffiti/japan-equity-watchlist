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

- `japan_equity_sector_map_v2.html` — **ライブダッシュボード本体**。113銘柄の分類マップに加え、各行に株価/PER/PBR/信用倍率/次回決算日をミニバーチャート（前日比%バッジ付き、赤=上昇・緑=下落）で表示し、11業種タブは業種平均前日比のヒートマップで自動着色。ページ上部には🌍**世界情勢サマリー**（日本・米国・中国・韓国、日本株への影響度を赤=追い風/緑=逆風で色分け）、下部には📰デイリーニュースログ（`#newslog`セクション）を持つ。
  - **🇯🇵/🇺🇸/🇨🇳/🇰🇷表示モード切替（2026-07-26追加）**: 世界情勢サマリーの「日本」「米国」「中国」「韓国」カードをタップすると、11業種テーブル全113行の銘柄コード・銘柄名・コメント・ファンダメンタルが、その銘柄に対応する海外上場銘柄（競合/顧客/供給元/投資家関係のいずれか）に一括で切り替わる（`applyMode('us'|'cn'|'kr'|'jp')`）。当初は国ごとに別セクションを新設する方式だったが「長すぎる」というフィードバックを受け、既存の11業種テーブルをその場で切り替える方式に置き換えた。`MODE_DATA`オブジェクトが`{base, price, asOf, cur}`をモードキー(`us`/`cn`/`kr`)ごとに保持する形で一般化されており、新しい国を追加する場合は対応する`XXBASE`/`XX_PRICE`オブジェクトを作り`MODE_DATA`に1エントリ足すだけでよい。対応銘柄が存在しない行（`該当なし`と判定された銘柄）はそのモードでも日本銘柄のまま表示される。副掲載（他セクション参照）行は海外対応データを持たないため全モードで変化しない。
  - **2026-07-25にデータ駆動方式へ全面改修済み**。表の見た目はHTMLに直書きせず、ファイル末尾の`<script>`内にあるJSオブジェクトから毎回自動生成される（`renderFundCells()`/`renderHeatmap()`/`renderWorld()`）。**この設計のおかげで日次更新はJSオブジェクトの中身を差し替えるだけで済み、HTML本体（テーブル行・nav等）は一切触らなくてよい。**
    - `BASE`: 銘柄コード→{基準株価p, PER, PBR, 信用倍率cr, 決算文言dec, 大分類番号s, ...}。決算発表・株式分割など「事案（イベント）」があった銘柄のみ、該当コードのオブジェクトを更新する（他の銘柄は触らない）。
    - `DAILY`: 銘柄コード→[当日株価, 前日比%] のペア。**日次更新で書き換えるのはここだけ**。PER/PBRはBASE値×(DAILY株価/BASE株価)で自動換算され、11業種タブの色もDAILYの前日比%から自動計算される。
    - `WORLD`: 地域キー（`japan`/`us`/`china`/`korea`、必要に応じて追加可）→{summary(日本語), en(英語), score(-2〜+2で日本株への影響度), asOf, source}。旧「一週間の投資情報まとめ」プロジェクトで**週次のみ**行っていた世界情勢分析を、この日次カードとして本プロジェクトに統合したもの。日次更新のたびに`summary`/`en`/`score`/`asOf`を書き換える。`korea`は半導体セクター（ウォッチリスト最大38銘柄）への連れ安・連れ高の影響が大きいため常設。
  - `USBASE`/`US_PRICE`、`CNBASE`/`CN_PRICE`、`KRBASE`/`KR_PRICE`（米国2026-07-26、中国・韓国2026-07-26追加）: 113銘柄それぞれに対応する米国・中国・韓国の上場銘柄（競合/顧客/供給元/投資家関係のいずれかで最も投資分析上意味のある1社、🇯🇵/🇺🇸/🇨🇳/🇰🇷表示モード切替でテーブルに表示）。キーはJPコード。各`XXBASE[code]`は{ティッカーt, 社名n, 基準PER/PBR, 決算日dec, 関係性rel, 選定理由why, (中国のみ)通貨cur:"HKD"未指定時はCNY}、`p`（基準株価）は起動時に対応する`XX_PRICE`から自動セットされる。**日次更新で書き換えるのは`US_PRICE`/`CN_PRICE`/`KR_PRICE`のみ**（PER/PBRはJPのBASE/DAILYと同じ`ratio = XX_PRICE/XXBASE.p`方式で自動換算）。関係性・選定理由（`rel`/`why`）はイベント発生時のみ更新。適切な対応銘柄が存在しない銘柄（例: 北川精機、浜松ホトニクス等ニッチ分野）は該当モードのオブジェクトにキー自体が存在せず、その行は自動的に日本銘柄表示にフォールバックする。全対応関係の一覧は本ファイルの`USBASE`/`CNBASE`/`KRBASE`定義を参照。
- `fundamentals/raw/batchNN.md` — 初回フル調査（バッチ調査エージェント）の生データ
- `fundamentals/raw/pricechg_batchN.md` — 株価・前日比%のみを取得する軽量バッチ調査の生データ（日次更新用）
- `fundamentals/watchlist_fundamentals_{date}.md` — フル調査を統合したマスターデータベース（詳細出典URL付き）。BASEオブジェクトの一次情報源。
- `daily/{date}.md` / `daily/{date}.html` / `daily/{date}_日次相場観.pdf` — `/jp-daily-view` コマンドで生成した日次の主観/客観市況コメント。**2026-07-27追加**: 通常の市況コメントに加え、①**資金フロー分析**（11業種の前日比ヒートマップ順位から資金の流出入を主観/客観で分析。日本に加え🇺🇸/🇨🇳/🇰🇷モードの業種平均も同様に分析）と②**本日の注目銘柄トップ3**（日本3＋対応米国/中国/韓国銘柄各3、計12銘柄を主観/客観で記載）を必ず含む。正午実行分（`daily/{date}_正午.md`）は③**午前中サマリー**（前場の値動きを主観/客観で記載。米国は取引時間外である旨を明記）も追加で含む。
- `.claude/commands/jp-daily-view.md` — 日次ルーティーン用スラッシュコマンド定義
- `scripts/Convert-DailyViewToPdf.ps1` — 日次コメントHTML→PDF変換スクリプト（PS1ファイルはUTF-8 BOM必須、日本語ファイル名が文字化けする）

## ファンダメンタルDBの更新方針 / Fundamentals DB Update Policy

- **日次更新（毎日行う想定）**: 113銘柄の株価・前日比%のみを軽量エージェント（4バッチ程度、Yahoo!ファイナンス優先・kabutan.jpは使用不可）で取得し、`japan_equity_sector_map_v2.html`末尾の`<script>`内`DAILY`オブジェクトを新しい値に置き換える（`AS_OF`日付も更新）。PER/PBR再計算とヒートマップ再着色はJSが自動で行うため、HTML本体・CSS・BASEオブジェクトは触らない。あわせて`US_PRICE`/`CN_PRICE`/`KR_PRICE`（対応する米国・中国・韓国銘柄の株価）も同様に軽量取得して置き換える（`USBASE`/`CNBASE`/`KRBASE`のPER/PBR/決算日/関係性は触らない。米国はstockanalysis.com、中国・韓国はeastmoney.com/stockanalysis.com優先）。「該当なし」判定で当該オブジェクトにキーが存在しない銘柄は調査不要。
- **イベント更新（決算発表・株式分割・上場廃止など、随時）**: 該当銘柄1件だけ`BASE`オブジェクトのそのコードのエントリを更新する（基準株価p・PER・PBR・信用倍率・決算文言dec等）。他の112銘柄には触れない。あわせて`#newslog`セクションに1行追記する。
- **フル更新（全113銘柄の株価・PER・PBR・信用倍率等の再調査）**: 月1回程度を目安に、`fundamentals/watchlist_fundamentals_{date}.md`を再作成し、その内容で`BASE`オブジェクト全体を更新する。
- 次回決算日が近い（1週間以内）銘柄は、日次コメントで優先的に言及する。

## 自動化について / On Automation

ローカルPCのCronはPCがスリープ中は発火しないため採用しない（[一週間の投資情報まとめ](../一週間の投資情報まとめ/CLAUDE.md)と同じ理由）。代わりに**2026-07-25、クラウド側のスケジュール実行（`schedule`スキル／`RemoteTrigger`）を設定済み**。クラウドエージェントはローカルPCにアクセスできないため、このプロジェクトはGitHubリポジトリ経由で運用する。

- **GitHubリポジトリ**: https://github.com/ChemGraffiti/japan-equity-watchlist （**2026-07-25にPublicへ変更**。理由: タブレット/スマホのOneDriveアプリのプレビューはJavaScriptを実行せず、数値・色が表示されないため、GitHub Pagesでブラウザから直接閲覧できるようにした）。ローカルの変更は都度 `git push origin main` してリポジトリに反映する。クラウド側の日次更新もこのリポジトリにpushされるため、ローカルで最新を見たい場合は `git pull` する。
- **GitHub Pages（スマホ・タブレット閲覧用）**: https://chemgraffiti.github.io/japan-equity-watchlist/ （`main`ブランチ・ルートから配信。`index.html`は`japan_equity_sector_map_v2.html`へ即時リダイレクトするだけの薄いファイル）。クラウドルーティーンが`git push`するたびに数分でこのURLにも自動反映される。**リポジトリがPublicのため、ここに機密情報（パスワード・APIキー等）を絶対にコミットしないこと。**
- **ルーティーンは1日2本**（いずれもSonnet 5で実行、Opusではない）:
  - **朝**: `trig_01MHvJpzmYjM1hoS8RqtCuKS`（名前:「日本株ウォッチリスト 日次更新」）。毎週月〜金曜 JST 6:00開始（cron: `0 21 * * 0-4` UTC）。7:00完了を目安に1時間のバッファ。`daily/{date}.md`に保存。
  - **正午**（2026-07-27追加）: `trig_01TN2HhJZhMKjvTcYPSqk7bk`（名前:「日本株ウォッチリスト 正午更新」）。毎週月〜金曜 JST 12:30開始（cron: `30 3 * * 1-5` UTC）。朝と同じ9ステップのフル版だが、`daily/{date}_正午.md`・Drive保存ファイル名・Gmail件名に「正午」を付けて朝の分と衝突しないようにしている。米国市場はこの時間まだ開いていないため`US_PRICE`調査は実質的に朝と同値になりやすい旨をプロンプトに明記済み（無駄を承知の上でユーザーが「フル版をそのまま2回」を選択）。
  - 管理・停止は両方とも https://claude.ai/code/routines から。
- **毎回の処理内容**（プロンプトは各ルーティーン本体に記載。ローカルの`.claude/commands/jp-daily-view.md`と同等の内容をクラウド実行版として保持。正午版は文言のみ「正午時点」向けに調整）:
  1. 113銘柄の株価前日比を調査し`DAILY`を更新。あわせて対応する米国・中国・韓国銘柄の株価も調査し`US_PRICE`/`CN_PRICE`/`KR_PRICE`を更新
  2. 市況調査（日本・米国・中国・韓国の世界情勢を含む）＋ニュースごとに関連するウォッチリスト銘柄を特定
  3. `WORLD`オブジェクトを更新（世界情勢サマリーカード）
  4. 主観/客観コメントを`daily/{date}.md`（正午版は`daily/{date}_正午.md`）に生成（関連銘柄を併記）
  5. `#newslog`に個別材料を追記
  6. GitHubにコミット・push
  7. Gmail下書きを作成（**自動送信ではなく下書きのみ**、Gmail連携にsend機能がないため）
  8. Googleドライブの「日本株ウォッチリスト」フォルダに日次コメント・ダッシュボードHTMLを保存
- ルーティーン本体を更新する際は、ローカルの`.claude/commands/jp-daily-view.md`を先に直してから、同じ変更内容を`RemoteTrigger`の`update`で**朝・正午の両方のルーティーン**のプロンプトに反映すること（3箇所が乖離しないように）。
- **既知の障害と対処（2026-07-27、3回連続発生・原因確定）**: 資金フロー分析・注目銘柄トップ3等の機能追加後、正午ルーティーンで3回連続の失敗が発生した。
  1. **1回目(10:30起動)**: 16並列のサブエージェントを起動し、セッション共有のWebSearch予算（200回）を数分で枯渇、プロキシが金融・ニュースサイトの大半を403で拒否して更新に失敗（ダッシュボードは正しく更新をスキップし既存データを保護）。
  2. **2回目(直後に再試行、「並列4〜6個までに統合」で対処)**: JP+US+CN+KRを同じバッチに統合した結果、1エージェントあたりの調査量が単純合算で最大4倍(110件超)に膨れ上がり、**3時間半経過しても応答・コミットなしでハング**（セッション`cse_01UypNK9zvTHSeKY7wN1rsU4`。ハングしたセッション自体を止める・強制終了する手段はAPI上見当たらなかった）。
  3. **3回目(市場ごとに8〜10バッチ＋20分タイムボックスで対処)**: ハングは解消したが、**JP113+US99+CN92+KR77≈381銘柄という調査総量自体がセッション共有のWebSearch予算(200回)を構造的に超えている**ことが判明。32/113銘柄のみ更新できた時点で予算切れとなり、タイムボックスに従って安全に部分更新・保存された（`daily/2026-07-27_正午.md`に詳細あり。データを壊さず「一部混在」である旨を明記する等、CLAUDE.mdの断定回避方針に沿った挙動）。
  - **確定した根本原因**: バッチの分け方や並列数の問題ではなく、**1セッションで賄える調査量の上限(≈200銘柄程度)を、4市場合計381銘柄という設計が構造的に超えている**こと。
  - **最終的な対処（2026-07-27時点）**: (a) **正午ルーティーンはUS_PRICEの調査を省略**（正午時点で米国市場は未開場のため朝と同じ値で調査が無駄）し、対象をJP113+CN92+KR77≈282銘柄に削減。(b) 可能な限り一覧ページのWebFetchで1回のリクエストから複数銘柄を読み取り、検索回数を節約する指示を追加。(c) それでも予算超過する場合はタイムボックスに従い部分更新で構わない（無理に完走させない）。`.claude/commands/jp-daily-view.md`と両クラウドルーティーンに反映済み。
  - **未解決・ユーザー判断が必要な点**: 上記対処後も朝ルーティーン（JP113+US99+CN92+KR77≈381銘柄）は依然として予算超過の可能性が高い。根本的には「`CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`の引き上げ（Anthropicサポート等に要相談）」または「US/CN/KRの更新頻度を毎日から数日おき等に落とす」のどちらかの判断がユーザーに必要。

- **続報（2026-07-28朝〜正午、4回目・5回目）**:
  4. **ユーザーの手動再テスト(7/27 14:49 UTC起動、US省略版)**: **18時間以上経過後も応答・コミットなし**（セッション`cse_01Cf1c6HPrno81mYyHdKK53x`）。タイムボックス指示があっても、ハングは完全には防げていないことが判明（発生頻度は不明だが、実測で4回中2回ハング）。
  5. **朝ルーティーンの本番実行(2026-07-28 6:00 JST予定分、実際の起動は05:20:35 UTC=14:20 JSTと8時間超遅延、2026-07-28 09:33 UTC時点で4時間以上経過してもコミットなし)**: これも**ハング中とみられる**。一方、同日12:30 JSTの正午ルーティーン（US省略版）は正常に完了し、14/113銘柄の部分更新＋新しい失敗モードを報告した：セッション内でWebFetch/WebSearchが**断続的に不安定**（一部サブエージェントは全URL 403、一部は正常）、および中国・韓国の取得値が前回比±35〜250%という**明らかに非現実的な値**だったため、データ品質チェックにより全件棄却し既存値を維持（正しい防御的判断）。
  - **総括（2026-07-28朝時点）**: 過去5回の実行のうち、ハング2回・予算切れによる部分更新2回・データ品質棄却による部分更新1回。**タイムボックス指示だけではハングを確実に防げていない**ため、根本対処には(a)ユーザーによるAnthropicサポートへの`CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`引き上げ相談、または(b)米中韓の更新頻度を毎日実行から間引く、のいずれかの意思決定が必要。**朝ルーティーンがハングした場合にダッシュボードのデータが古いまま止まるリスクがある**ため、次回ユーザーが確認した際にダッシュボードの`AS_OF`が古い場合は、`RemoteTrigger`で朝ルーティーンを手動再実行することを推奨。
  - **2026-07-28 09:31 UTC時点で重要な市場ニュースあり**: 本日前場、半導体セクター中心に日経平均-4.44%急落、キオクシアHD一時ストップ安-18%、韓国KOSPI一時-8%超（サーキットブレーカー発動）。詳細は`daily/2026-07-28_正午.md`参照。この情報自体は正午ルーティーンが正常に取得済み。

Local Cron is not used since it doesn't fire while the PC is asleep. Instead, a **cloud-scheduled routine** (via the `schedule` skill / `RemoteTrigger`) was set up on 2026-07-25. Since cloud agents can't reach the local PC, this project is operated through a GitHub repository (see above) that the cloud routine clones, updates, and pushes to every weekday morning (JST 6:00, targeting 7:00 completion). It also drafts a Gmail summary (draft only — the connector has no send capability) and saves snapshots to Google Drive.

## 実行方法 / How to Run

- 初回・フル更新: ユーザーの指示に応じて、113銘柄を約12銘柄ずつ10バッチに分割し、並列エージェント（Opus使用可）で株価・PER・PBR・信用倍率・次回決算日・その他ファンダメンタル・IR・関連ニュースを調査し、`fundamentals/watchlist_fundamentals_{date}.md` に統合したうえで、その内容で`japan_equity_sector_map_v2.html`の`BASE`オブジェクトを更新する。
- 日次（ローカル手動）: `/jp-daily-view` を実行すると、①113銘柄の株価・前日比%を軽量バッチ調査で取得して`DAILY`オブジェクトを差し替え、②世界情勢を調査して`WORLD`オブジェクトを更新、③マスターDBと当日のニュースを踏まえた主観/客観コメント（関連銘柄併記）を`daily/{date}.md`に生成、④個別材料があれば`#newslog`に追記する。
- 日次（クラウド自動）: 上記「自動化について」のクラウドルーティーンが平日毎朝自動実行する。ローカルで最新を見るには`git pull`が必要。
- 自動投稿・自動売買は一切行わない。
