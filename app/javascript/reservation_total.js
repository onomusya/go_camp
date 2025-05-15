// helper: 数字文字列を int に、安全に
const toInt = s => parseInt(s, 10) || 0;

// MutationObserverインスタンスを管理する変数
let totalCalculationObserver = null;

// 合計金額を計算し更新する関数
const updateTotalPrice = () => {
  console.log("Debug (Total): updateTotalPrice called."); // デバッグログ追加

  // --- START: gon と site_price への安全なアクセス ---
  let sitePrice = 0;
  // window.gon が存在し、かつ window.gon.site_price が数値または数値文字列として存在する場合に読み取る
  if (typeof window.gon !== 'undefined' && typeof window.gon.site_price !== 'undefined') {
      sitePrice = toInt(window.gon.site_price);
      console.log("Debug (Total): sitePrice from gon:", sitePrice); // デバッグログ追加
  } else {
      console.warn("Debug (Total): window.gon or site_price is undefined when calculating total. Cannot get site price."); // 警告ログ追加
      // site_price が取得できない場合、計算はアイテム料金のみで行われます (sitePrice は 0 のまま)
  }
  // --- END: gon と site_price への安全なアクセス ---


  // 2) 各アイテムの数量×価格を合算
  let itemsTotal = 0;
  document
    .querySelectorAll("input[name^='reservation[rental_item_ids]']")
    .forEach(input => {
      const itemId = input.name.match(/\d+/)[0];
      const qty    = toInt(input.value);
      if (qty <= 0) return;

      // DOM上に price 情報を持たせている想定
      const price = toInt(input.dataset.price);
      itemsTotal += price * qty;
    });
    console.log("Debug (Total): itemsTotal:", itemsTotal); // デバッグログ追加

  // 3) 合計 = サイト + アイテム
  const total = sitePrice + itemsTotal;
  console.log("Debug (Total): Calculated total:", total); // デバッグログ追加

  // 4) ビューの合計金額フィールドに反映
  // --- START: セレクタ修正 ---
  const totalField = document.querySelector("input[name='reservation[total_price]']"); // セレクタ修正: 末尾に ']' を追加
  // --- END: セレクタ修正 ---
  if (totalField) {
    totalField.value = total;
    console.log("Debug (Total): Total price field updated to:", total); // デバッグログ追加
  } else {
    console.warn("Debug (Total): Total price field not found."); // 警告ログ追加
  }
};

// gon.site_price と必要なDOM要素が利用可能になるのを待ってから
// updateTotalPrice を実行するための関数
const waitForGonAndElementsAndCalculate = () => {
    console.log("Debug (Total): waitForGonAndElementsAndCalculate called.");

    // gon.site_price が利用可能かチェック
    const gonReady = typeof window.gon !== 'undefined' && typeof window.gon.site_price !== 'undefined';

    // 必要なDOM要素（合計金額フィールドとアイテム数量入力）が利用可能かチェック
    const totalField = document.querySelector("input[name='reservation[total_price]']");
    const itemInputs = document.querySelectorAll("input[name^='reservation[rental_item_ids]']");
    const elementsReady = !!totalField && itemInputs.length > 0; // 合計フィールドがあり、アイテム入力が1つ以上あるか

    console.log("Debug (Total): Status check - gonReady:", gonReady, "elementsReady:", elementsReady);

    // 両方準備ができたら合計金額を計算し、オブザーバーを停止
    if (gonReady && elementsReady) {
        console.log("Debug (Total): gon and elements are ready. Performing initial calculation and setting listeners.");

        // 初回計算を実行
        updateTotalPrice();

        // アイテム数量変更時のリスナーを設定
        itemInputs.forEach(input => {
            // 重複してリスナーを追加しないようにチェック (オプション)
            // input.removeEventListener("input", updateTotalPrice); // 念のため既存リスナーを削除
            input.addEventListener("input", updateTotalPrice);
            console.log(`Debug (Total): Added input listener for item ${input.name}.`);
        });

        // オブザーバーがアクティブだった場合、監視を停止
        if (totalCalculationObserver) {
            totalCalculationObserver.disconnect();
            totalCalculationObserver = null;
            console.log("Debug (Total): MutationObserver disconnected after setup.");
        }

    } else {
        console.log("Debug (Total): gon or elements not ready yet. Waiting...");
        // まだ準備ができていない場合は、MutationObserverが再度呼び出すのを待つ
    }
};


// ページロード時に MutationObserver を開始
window.addEventListener("turbo:load", () => {
  console.log("Debug (Total): turbo:load event fired for reservation_total.js");

  // 前のページ訪問からのアクティブなオブザーバーを停止
  if (totalCalculationObserver) {
      totalCalculationObserver.disconnect();
      totalCalculationObserver = null;
      console.log("Debug (Total): Disconnected previous MutationObserver on turbo:load.");
  }

  // gon.site_price と必要なDOM要素を待つ新しいMutationObserverをセットアップ
  totalCalculationObserver = new MutationObserver(waitForGonAndElementsAndCalculate);
  totalCalculationObserver.observe(document.body, {
    childList: true, // 子ノードの追加・削除を監視
    subtree: true    // サブツリー全体を監視対象とする
  });
  console.log("Debug (Total): MutationObserver started on turbo:load.");

  // オブザーバーを開始した直後に一度チェックを実行
  // 要素とgonが既に存在する場合にすぐに初期化を行うため
  console.log("Debug (Total): Initial check after turbo:load.");
  waitForGonAndElementsAndCalculate();

});

// Turboキャッシュ前のイベントをリッスンし、オブザーバーをクリーンアップ
window.addEventListener("turbo:before-cache", () => {
    console.log("Debug (Total): turbo:before-cache event fired.");
     if (totalCalculationObserver) {
        totalCalculationObserver.disconnect();
        totalCalculationObserver = null;
        console.log("Debug (Total): MutationObserver disconnected before Turbo cache.");
    }
});

// Turbo新しいページレンダリング前のイベントをリッスンし、オブザーバーをクリーンアップ
window.addEventListener("turbo:before-render", () => {
    console.log("Debug (Total): turbo:before-render event fired.");
     if (totalCalculationObserver) {
        totalCalculationObserver.disconnect();
        totalCalculationObserver = null;
        console.log("Debug (Total): MutationObserver disconnected before Turbo render.");
    }
});

// DOMContentLoaded は通常不要 (TurboがDOM管理するため)
// window.addEventListener("DOMContentLoaded", () => { ... });
