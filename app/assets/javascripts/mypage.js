//= require jquery3
//= require popper
//= require rails-ujs
//= require bootstrap-material-design/dist/js/bootstrap-material-design.js
//= require activestorage

function previewFileWithId(selector){
    // inputタグの取得
    const target = this.event.target;
    // ファイルの内容の取得
    const file = target.files[0];
    // ファイルを読み込むためのインスタンスをまずは生成
    const reader = new FileReader();
    // ファイルを読み込んだら(onload)selectorのsrcをreaderのurlで書き換える
    reader.onloadend = function (){
        selector.src = reader.result;
    }
    // ファイルがあればURLを取得して格納
    if (file) {
        reader.readAsDataURL(file);
    } else {
        selector.src = "";
    }
}