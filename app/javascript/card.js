// 現在のTurbo訪問でPAY.JPが初期化されたかどうかを追跡する変数
// グローバルスコープに紐付けて宣言し、Turboイベントリスナーからアクセス可能にする
window.payjpInitializedForVisit = false;
// アクティブなMutationObserverインスタンスを管理する変数
// グローバルスコープに紐付けて宣言し、Turboイベントリスナーからアクセス可能にする
window.currentMutationObserver = null;

// マウント対象の要素のセレクタを定義
const numberFormSelector = '#number-form';
const expiryFormSelector = '#expiry-form';
const cvcFormSelector = '#cvc-form';
const formSelector = '#charge-form';

// PAY.JPの実際の初期化とElementのマウントを行う関数
const initializeAndMountPayjp = () => {
    // この訪問で既に初期化されているかチェック
    if (window.payjpInitializedForVisit) {
         return; // 再初期化を避ける
    }

    // --- START: gon と 公開鍵のチェック ---
    // window.gon が存在し、かつ window.gon.public_key が文字列として存在するかを確認
    if (typeof window.gon === 'undefined' || typeof window.gon.public_key !== 'string' || !window.gon.public_key) {
         console.warn("PAY.JP setup warning: Public key not available. Retrying on next DOM change."); // 警告は残す
         // gon がまだ準備できていない場合は初期化できないので、ここで処理を中断
         // MutationObserver が再度呼び出されるのを待つ
         return;
    }
    const publicKey = window.gon.public_key; // window.gon から公開鍵を取得
    // --- END: gon と 公開鍵のチェック ---


    // --- START: 必要なDOM要素のチェック ---
    // 要素を取得（存在チェックは引き続き行う）
    const numberForm = document.querySelector(numberFormSelector);
    const expiryForm = document.querySelector(expiryFormSelector);
    const cvcForm = document.querySelector(cvcFormSelector);
    const form = document.querySelector(formSelector);

    if (!numberForm || !expiryForm || !cvcForm || !form) {
        // 必要な要素が見つからない場合はマウントできない
        // MutationObserver が再度呼び出されるのを待つ
        return;
    }
    // --- END: 必要なDOM要素のチェック ---


    // すべてのチェックがパスした場合、初期化とマウントに進む
    try {
        // 公開鍵を使って PAY.JP ライブラリを初期化
        const payjp = Payjp(publicKey);
        const elements = payjp.elements();

        window.payjpInitializedForVisit = true; // この訪問で初期化済みとマーク

        // Elementsの生成とマウント
        const numberElement = elements.create('cardNumber');
        const expiryElement = elements.create('cardExpiry');
        const cvcElement = elements.create('cardCvc'); // 正しいElementタイプは 'cardCvc'

        // マウント引数はセレクタ文字列を渡す
        numberElement.mount(numberFormSelector);
        expiryElement.mount(expiryFormSelector);
        cvcElement.mount(cvcFormSelector);

        // フォームのSubmitイベントリスナーの設定 (重複して追加しないようにチェック)
        if (!form.dataset.payjpListenerAdded) {
             form.addEventListener("submit", (e) => {
                e.preventDefault(); // デフォルトのフォーム送信を防止

                // Submitボタンを無効化して二重送信を防ぐ
                const submitButton = form.querySelector('input[type="submit"]');
                if (submitButton) {
                    submitButton.disabled = true;
                    submitButton.value = '処理中...'; // 例: ボタンテキストを変更
                }

                // PAY.JPトークンを作成
                payjp.createToken(numberElement).then(function (response) {
                  if (response.error) {
                    // トークン作成失敗時
                    console.error("PAY.JP Token creation failed:", response.error.code, response.error.message); // 開発者向けエラーログ
                    alert("カード情報の送信に失敗しました。\nエラー: " + response.error.message); // ユーザーへのフィードバック

                    // エラー発生時はボタンを再度有効化
                    if (submitButton) {
                        submitButton.disabled = false;
                        submitButton.value = '予約する';
                    }

                  } else {
                    // トークン作成成功時
                    const token = response.id;

                    // フォームにトークンを隠しフィールドとして追加
                    const tokenObj = `<input value="${token}" name="token" type="hidden">`;
                    form.insertAdjacentHTML("beforeend", tokenObj);

                    // カード入力フィールドをクリア
                    numberElement.clear();
                    expiryElement.clear();
                    cvcElement.clear();

                    // プログラムからフォームを送信
                    form.submit();

                    // 注意: フォーム送信後はページ遷移するため、ボタンは無効化されたままになります
                  }
                }).catch(function(error) {
                  // トークン作成中の予期せぬエラー (例: ネットワーク問題)
                  console.error("An unexpected error occurred during token creation:", error); // 開発者向けエラーログ
                  alert("決済処理中に予期せぬエラーが発生しました。時間をおいて再度お試しください。"); // ユーザーへのフィードバック

                  // エラー発生時はボタンを再度有効化
                  if (submitButton) {
                      submitButton.disabled = false;
                      submitButton.value = '予約する';
                  }
                });
              });
             form.dataset.payjpListenerAdded = 'true'; // リスナー追加済みとマーク
        }


        // オブザーバーがアクティブだった場合、要素が見つかったので監視を停止
        if (window.currentMutationObserver) {
            window.currentMutationObserver.disconnect();
            window.currentMutationObserver = null;
        }

    } catch (e) {
        // PAY.JP初期化またはマウント中のエラーをキャッチ
        console.error("PAY.JP Initialization or Mounting Error:", e); // 開発者向けエラーログ
        alert("決済システムのセットアップに失敗しました。サイト管理者にお問い合わせください。"); // ユーザーへのフィードバック

        // 致命的なエラー発生時はオブザーバーを停止
         if (window.currentMutationObserver) {
            window.currentMutationObserver.disconnect();
            window.currentMutationObserver = null;
        }
    }
};

// --- イベントリスナー ---

// Turboページ読み込みイベントをリッスン
window.addEventListener("turbo:load", () => {
    // 新しいページ訪問のために初期化フラグをリセット
    window.payjpInitializedForVisit = false;
    // 前のページ訪問からのアクティブなオブザーバーを停止
    if (window.currentMutationObserver) {
        window.currentMutationObserver.disconnect();
        window.currentMutationObserver = null;
    }

    // 要素とgonを待つ新しいMutationObserverをセットアップ
    // MutationObserverのコールバックで initializeAndMountPayjp を呼び出す
    window.currentMutationObserver = new MutationObserver(initializeAndMountPayjp);
    window.currentMutationObserver.observe(document.body, {
      childList: true, // 直接の子ノードの追加・削除を監視
      subtree: true    // サブツリー全体を監視対象とする
    });

    // オブザーバーを開始した直後に一度 initializeAndMountPayjp を呼び出す
    // 要素とgonが既に存在する場合にすぐに初期化を行うため
    initializeAndMountPayjp();

});

// Turboキャッシュ前のイベントをリッスンし、オブザーバーをクリーンアップ
window.addEventListener("turbo:before-cache", () => {
     if (window.currentMutationObserver) {
        window.currentMutationObserver.disconnect();
        window.currentMutationObserver = null;
    }
});

// Turbo新しいページレンダリング前のイベントをリッスンし、オブザーバーをクリーンアップ
window.addEventListener("turbo:before-render", () => {
     if (window.currentMutationObserver) {
        window.currentMutationObserver.disconnect();
        window.currentMutationObserver = null;
    }
});

// DOMContentLoaded は通常不要 (TurboがDOM管理するため)
// window.addEventListener("DOMContentLoaded", () => { ... });