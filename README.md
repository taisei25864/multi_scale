# nutribalance（仮）— レシピ入力から「残り必要栄養」を出すRuby製CLI

朝・昼・夜の食事内容（食品と量）を入力すると、その食事で摂取した栄養素を集計し、**1日目標との差分（残り／超過）**を表示します。  
また、朝のみ入力された場合などに、**残り必要量を「昼＋夜」に配分した目安**も出力します。

---

## 特徴

- **Ruby製CLI（Command Line Interface）**として動作
- 食品データ・目標値・配分比率を **YAML** で管理（編集しやすい）
- その日の食事ログも YAML に保存（ローカル：`~/.nutribalance/state.yml`）
- 出力は表形式（`tty-table`）で見やすく表示

---

## 動作環境

- Ruby 3.2+（推奨）
- macOS / Linux / WSL（想定）

---

## インストール

### 1) リポジトリを取得

```bash
git clone <this-repo>
cd nutribalance
```

### 2) リポジトリを取得

```bash
bundle install
```

### 3) CLIを実行（開発時）

```
bundle exec nutribalance --help
```

gemとして配布する場合は gemspec を用意し、gem build / gem install を使う形にしてください。

## 使い方

### 今日の食事を追加する

```bash
bundle exec nutribalance add --meal breakfast shokupan:60 yogurt_plain:100
```

- `--meal`：`breakfast` / `lunch` / `dinner`
- `food:grams`：食品キーと量（g）  
  例：`shokupan:60` は食パン60g

### 今日のレポートを表示する

```bash
bundle exec nutribalance report
```

出力内容（例）：

- 摂取量（栄養素別）
- 1日目標との差分（残り：正、超過：負）
- （任意）朝だけ入力された場合：残り必要量の昼夜配分（比率はYAMLで調整）

### 今日の記録をリセット

```bash
bundle exec nutribalance reset
```

### 食品データ（YAML）をCLIから追加する

食品データは data/foods.yml のみを参照します。nutribalance foods add により data/foods.yml に直接追記されます。

#### 追加

```bash
bundle exec nutribalance foods add \
  --key natto \
  --label "納豆" \
  --per100g energy_kcal=200 protein_g=16.5 fat_g=10.0 carb_g=12.1 salt_g=0.01
```

#### 一覧

```bash
bundle exec nutribalance foods list
```

#### 詳細

```bash
bundle exec nutribalance foods show --key natto
```

#### 検索

```bash
bundle exec nutribalance foods search yo
```


## 設定ファイル（YAML）

設定は3種類に分けています。YAMLは「人間が読める設定（Human-readable configuration）」として扱い、授業課題でも説明しやすい構成にしています。

### 1) 目標値プロファイル `config/profile.yml`

- 1日目標（例：エネルギー、たんぱく質等）をプロファイルとして定義します。
- **デフォルト値は例**です。正確な目標は年齢・性別・身体活動レベル等で変わるため、根拠資料に基づいて調整してください。

```yaml
profiles:
  default_adult:
    label: "成人(例)"
    targets:
      energy_kcal: 2200
      protein_g: 65
      fat_g: 60
      carb_g: 300
      fiber_g: 21
      salt_g: 7.5
```

### 2) 食事配分比率 `config/meal_ratios.yml`

残り必要量を、昼と夜にどう配分するかの比率です。

```yaml
ratios:
  breakfast: 0.25
  lunch: 0.35
  dinner: 0.40
```

> 例：朝だけ入力された場合、残り必要量を `lunch : dinner = 0.35 : 0.40` の比で配分して目安を表示します。

### 3) 食品データ `data/foods.yml`

食品ごとの栄養素（可食部100gあたり）を定義します。

```yaml
foods:
  shokupan:
    label: "食パン"
    per_100g:
      energy_kcal: 260
      protein_g: 9.0
      fat_g: 4.2
      carb_g: 46.0
      salt_g: 1.2
  yogurt_plain:
    label: "ヨーグルト(無糖)"
    per_100g:
      energy_kcal: 62
      protein_g: 3.6
      fat_g: 3.0
      carb_g: 4.7
      salt_g: 0.1
```

---

## 計算仕様（設計メモ）

食品を栄養素ベクトル（nutrition vector）として扱い、次の処理を行います。

1. 入力 `food:grams` を読み取り
2. `per_100g` を `grams/100` 倍して栄養素量を計算
3. 食事単位→日単位へ合算
4. 残量を `remaining = targets - totals` として算出  
   - `remaining > 0`：不足  
   - `remaining < 0`：超過
5. 朝のみ入力などの場合、`remaining` を食事比率で配分して「昼・夜の目安」を出力
