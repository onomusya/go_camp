require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    let(:user) { build(:user) }

    context '新規登録できるとき' do
      it '全ての項目が存在すれば登録できる' do
        expect(user).to be_valid
      end
    end

    context '新規登録できないとき' do
      it '名前が空では登録できない' do
        user.name = ''
        expect(user).to be_invalid
        expect(user.errors[:name]).to include("can't be blank")
      end

      it 'メールアドレスが空では登録できない' do
        user.email = ''
        expect(user).to be_invalid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it '同じメールアドレスでは登録できない' do
        create(:user, email: user.email)
        expect(user).to be_invalid
        expect(user.errors[:email]).to include("has already been taken")
      end

      it 'パスワードが空では登録できない' do
        user.password = ''
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'パスワードが6文字未満では登録できない' do
        user.password = '12345'
        user.password_confirmation = '12345'
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it 'パスワードと確認用パスワードが一致していないと登録できない' do
        user.password_confirmation = 'different'
        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it '電話番号が空では登録できない' do
        user.phone_number = ''
        expect(user).to be_invalid
        expect(user.errors[:phone_number]).to include("can't be blank")
      end

      it '郵便番号が空では登録できない' do
        user.postal_code = ''
        expect(user).to be_invalid
        expect(user.errors[:postal_code]).to include("can't be blank")
      end

      it '住所が空では登録できない' do
        user.address = ''
        expect(user).to be_invalid
        expect(user.errors[:address]).to include("can't be blank")
      end
    end
  end
end
