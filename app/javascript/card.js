// app/javascript/card.js

// グローバルスコープの変数定義
let payjpInstance = null; // Payjpインスタンスを保持 (ページ遷移後も維持する)
let numberElement = null;
let expiryElement = null;
let cvcElement    = null;
let chargeFormElementCache = null; // 現在のフォーム要素への参照をキャッシュ
let formSubmitHandlerInstance = null; // submitイベントハンドラへの参照

/**
 * PayJP Elements とイベントリスナーのクリーンアップ処理
 * 既存のPayJP Elementをアンマウントし、イベントリスナを削除、関連変数をリセットする。
 * payjpInstance自体はリセットしない。
 */
function cleanupPayjpElementsAndListeners() {
  console.log("Card.js: cleanupPayjpElementsAndListeners 実行開始");

  // フォームとイベントリスナのクリーンアップ
  if (chargeFormElementCache && formSubmitHandlerInstance) {
    chargeFormElementCache.removeEventListener("submit", formSubmitHandlerInstance);
    console.log("Card.js: submit イベントリスナーを以前のフォームから削除しました。");
  }

  // PayJP Elementのアンマウント
  if (numberElement) {
    try {
      numberElement.unmount();
      console.log("Card.js: numberElement をアンマウントしました。");
    } catch (e) {
      console.warn("Card.js: numberElement.unmount() でエラーが発生しました。", e);
    }
  }
  if (expiryElement) {
    try {
      expiryElement.unmount();
      console.log("Card.js: expiryElement をアンマウントしました。");
    } catch (e) {
      console.warn("Card.js: expiryElement.unmount() でエラーが発生しました。", e);
    }
  }
  if (cvcElement) {
    try {
      cvcElement.unmount();
      console.log("Card.js: cvcElement をアンマウントしました。");
    } catch (e) {
      console.warn("Card.js: cvcElement.unmount() でエラーが発生しました。", e);
    }
  }

  // Element とフォーム関連のグローバル変数のリセット
  numberElement = null;
  expiryElement = null;
  cvcElement    = null;
  chargeFormElementCache = null;
  formSubmitHandlerInstance = null;

  console.log("Card.js: Payjp Elements と Listener のクリーンアップが完了しました。");
}

/**
 * PayJPの初期化とElementのマウント処理
 */
function initPayjp() {
  cleanupPayjpElementsAndListeners();
  console.log("Card.js: initPayjp 実行開始。Elements/Listeners の事前クリーンアップ完了。");

  const currentChargeForm = document.getElementById("charge-form");
  if (!currentChargeForm) {
    console.log("Card.js: フォーム要素 (id='charge-form') が現在のページに見つかりません。PayJP初期化をスキップします。");
    return;
  }
  chargeFormElementCache = currentChargeForm;

  if (!window.gon?.public_key) {
    console.error("Card.js: gon.public_key が設定されていません。PayJP初期化をスキップします。");
    return;
  }

  const numberFormContainerId = "number-form";
  const expiryFormContainerId = "expiry-form";
  const cvcFormContainerId    = "cvc-form";

  const numberFormContainer = document.getElementById(numberFormContainerId);
  const expiryFormContainer = document.getElementById(expiryFormContainerId);
  const cvcFormContainer    = document.getElementById(cvcFormContainerId);

  if (!numberFormContainer || !expiryFormContainer || !cvcFormContainer) {
    console.error("Card.js: PayJP Element のマウント先コンテナ要素が見つかりません。PayJP初期化をスキップします。");
    return;
  }

  // マウント前にコンテナをクリアする
  try {
    numberFormContainer.innerHTML = '';
    expiryFormContainer.innerHTML = '';
    cvcFormContainer.innerHTML = '';
    console.log("Card.js: Elementマウントコンテナをクリアしました。");
  } catch (e) {
    console.warn("Card.js: Elementマウントコンテナのクリア中にエラーが発生しました。", e);
    // このエラーは致命的ではないかもしれないので、処理を続行
  }

  try {
    if (!payjpInstance) {
      console.log("Card.js: payjpInstance が存在しないため、新規に作成します。");
      payjpInstance = Payjp(window.gon.public_key);
      if (!payjpInstance) {
          console.error("Card.js: Payjp(gon.public_key) の呼び出しに失敗しました。インスタンスが作成できませんでした。");
          return;
      }
      console.log("Card.js: Payjp インスタンスの新規作成が完了しました。");
    } else {
      console.log("Card.js: 既存の payjpInstance を再利用します。");
    }

    const elements = payjpInstance.elements();

    numberElement = elements.create("cardNumber");
    expiryElement = elements.create("cardExpiry");
    cvcElement    = elements.create("cardCvc");

    numberElement.mount(`#${numberFormContainerId}`);
    expiryElement.mount(`#${expiryFormContainerId}`);
    cvcElement.mount(`#${cvcFormContainerId}`);

    console.log("Card.js: PayJP Elements の作成とマウントが完了しました。");

  } catch (e) {
    console.error("Card.js: PayJP の初期化、または Element の作成・マウント中にエラーが発生しました。", e);
    if (e.message && e.message.includes("既にインスタンス化されています")) {
        console.warn("Card.js: '既にインスタンス化されています' エラーをキャッチ。payjpInstance はクリアしません。");
    }
    cleanupPayjpElementsAndListeners(); // エラー発生時は念のため再度クリーンアップ
    return;
  }

  formSubmitHandlerInstance = (event) => {
    event.preventDefault();

    const submitButton = currentChargeForm.querySelector('input[type="submit"]');
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.value = "処理中…";
    }

    if (!numberElement || !payjpInstance) {
        console.error("Card.js: cardNumber Element または payjpInstance が初期化されていません。トークン作成をスキップします。");
        alert("カード情報コンポーネントの初期化に問題がありました。ページを再読み込みしてください。");
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.value = "予約する";
        }
        return;
    }

    // トークン作成前に、Elementがマウントされているか簡易的に確認（デバッグ用）
    // 注意: Pay.JP Elementの内部iframeに直接アクセスすることは推奨されません。
    // これはあくまでデバッグのための間接的な確認の試みです。
    if (document.getElementById(numberFormContainerId) && !document.getElementById(numberFormContainerId).querySelector('iframe')) {
        console.warn(`Card.js: #$${numberFormContainerId} にiframeが見つかりません。マウントに問題があった可能性があります。`);
    }


    payjpInstance.createToken(numberElement).then(res => {
      if (res.error) {
        alert(`カード情報の処理でエラーが発生しました: ${res.error.message}`);
        if (submitButton) {
          submitButton.disabled = false;
          submitButton.value = "予約する";
        }
        return;
      }

      const existingTokenInput = currentChargeForm.querySelector('input[name="token"]');
      if (existingTokenInput) {
        existingTokenInput.remove();
      }
      currentChargeForm.insertAdjacentHTML("beforeend",
        `<input type="hidden" name="token" value="${res.id}">`
      );
      currentChargeForm.submit();

    }).catch(err => {
      console.error("Card.js: トークン作成またはフォーム送信プロセスでエラーが発生しました。", err);
      // エラーオブジェクト全体をログに出力して詳細を確認
      console.error("Card.js: エラー詳細:", err);
      alert("決済処理中に予期せぬエラーが発生しました。");
      if (submitButton) {
        submitButton.disabled = false;
        submitButton.value = "予約する";
      }
    });
  };

  currentChargeForm.addEventListener("submit", formSubmitHandlerInstance);
  console.log("Card.js: submit イベントリスナーを現在の charge-form に登録しました。");
  console.log("Card.js: Payjp の初期化とマウント処理がすべて完了しました。");
}

// --- Turbo Drive イベントリスナー ---
document.addEventListener("turbo:load", initPayjp);
document.addEventListener("turbo:before-render", () => {
  console.log("Card.js: turbo:before-render イベント検知。Elements/Listeners をクリーンアップします。");
  cleanupPayjpElementsAndListeners();
});
