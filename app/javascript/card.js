window.addEventListener("turbo:load", () => {
    // フォームだけ取得。numDiv / expDiv / cvcDiv は使わない
    const form = document.getElementById("charge-form");
    if (!form) {
      console.log("Card.js: カードフォームがないので何もしません");
      return;
    }
  
    // gon の公開鍵チェック
    if (!window.gon || !gon.public_key) {
      console.error("Card.js: gon.public_key がありません");
      return;
    }
  
    // Pay.jp v2 の正しい初期化
    const payjp = Payjp(gon.public_key);
    const elements = payjp.elements();
  
    // Element を作成・マウント（文字列セレクタを渡す）
    const numberElement = elements.create("cardNumber");
    const expiryElement = elements.create("cardExpiry");
    const cvcElement    = elements.create("cardCvc");
  
    numberElement.mount("#number-form");
    expiryElement.mount("#expiry-form");
    cvcElement.mount("#cvc-form");
  
    // 送信ハンドラ
    form.addEventListener("submit", e => {
      e.preventDefault();
      const btn = form.querySelector('input[type="submit"]');
      if (btn) { btn.disabled = true; btn.value = "処理中…"; }
  
      payjp.createToken(numberElement).then(res => {
        if (res.error) {
          alert(`カード情報エラー: ${res.error.message}`);
          if (btn) { btn.disabled = false; btn.value = "予約する"; }
          return;
        }
        form.insertAdjacentHTML("beforeend",
          `<input type="hidden" name="token" value="${res.id}">`
        );
        form.submit();
      }).catch(err => {
        console.error("Card.js token error:", err);
        alert("決済処理中にエラーが発生しました");
        if (btn) { btn.disabled = false; btn.value = "予約する"; }
      });
    });
  });