#!/bin/bash
# open video file with mpv and resize it to the video's resolution in Hyprland
open_video_dynamic() {
    local video_file="$1"
    echo "動画ファイル: $video_file"
    if [[ ! -f "$video_file" ]]; then
        echo "ファイルが見つかりません: $video_file"
        return 1
    fi
    
    # 動画サイズを取得
    local width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$video_file")
    local height=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$video_file")
    
    if [[ -n "$width" && -n "$height" ]]; then
        echo "動画サイズ: ${width}x${height}"
        
        # バックグラウンドでmpvを起動
        mpv --no-keepaspect-window "$video_file" &
        local mpv_pid=$!
        echo "mpvプロセスID: $mpv_pid"
        
        # 少し待ってからウィンドウを見つけてリサイズ
        sleep 1
        
        # mpvのウィンドウアドレスを取得
        local window_address=$(hyprctl clients -j | jq -r ".[] | select(.class == \"mpv\") | .address")
        echo "Window Address: $window_address"
        if [[ -n "$window_address" ]]; then
            # ウィンドウをフロート状態
            #hyprctl dispatch togglefloating address:$window_address
            # -> windowruleで設定しているので不要
            # ウィンドウサイズを動画サイズに設定
            hyprctl dispatch resizewindowpixel exact ${width} ${height},address:$window_address
            # ウィンドウを中央に配置
            hyprctl dispatch centerwindow
            echo "ウィンドウサイズを ${width}x${height} に設定しました"
        else
            echo "mpvウィンドウが見つかりませんでした"
        fi
        
        # プロセスの終了を待つ
        wait $mpv_pid
    else
        echo "動画サイズを取得できませんでした"
        mpv "$video_file"
    fi
}

open_video_dynamic "$1"
