# Настройки для хрома
$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens | Sort-Object { $_.Bounds.X }
$leftX = $screens[0].Bounds.X
$rightX = $screens[-1].Bounds.X
$half = [Math]::Floor($screens[0].Bounds.Width / 2)
$height = $screens[0].Bounds.Height - 40

# WinAPI
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr i, int X, int Y, int cx, int cy, uint f);
    [DllImport("user32.dll")] public static extern int EnumWindows(EnumWindowsProc f, IntPtr p);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int p);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    public delegate bool EnumWindowsProc(IntPtr h, IntPtr p);
}
"@

$SWP = 0x0040
$RESTORE = 9

# Получить окна Chrome
function Get-ChromeWindows {
    $list = [System.Collections.ArrayList]::new()
    $cb = { param($h, $p) if ([WinAPI]::IsWindowVisible($h)) { $id=0; [WinAPI]::GetWindowThreadProcessId($h, [ref]$id); if ((Get-Process -Id $id -EA 0).ProcessName -eq "chrome") { $list.Add($h) } }; return $true }
    [WinAPI]::EnumWindows([WinAPI+EnumWindowsProc]{ $cb.Invoke($args[0], $args[1]) }, 0)
    $list
}

# Переместить окно по одному из возможных заголовков окна
function Move-Window {
    param($Titles, $X, $Y, $W, $H)
    if ($Titles -isnot [array]) { $Titles = @($Titles) }
    
    foreach ($h in Get-ChromeWindows) {
        $sb = [System.Text.StringBuilder]::new(256)
        [WinAPI]::GetWindowText($h, $sb, 256)
        $title = $sb.ToString()
        foreach ($t in $Titles) {
            if ($title -match $t) {
                [WinAPI]::ShowWindow($h, $RESTORE)
                [WinAPI]::SetForegroundWindow($h)
                Start-Sleep -Milliseconds 200
                [WinAPI]::SetWindowPos($h, 0, $X, $Y, $W, $H, $SWP)
                return $true
            }
        }
    }
    $false
}

# --- Запуск ---
Stop-Process -Name chrome -Force -EA 0
Start-Sleep 2

# Запускаем впн-ы, телеграмм, елемент
Start-Process "C:\Program Files\Crypto Pro\NGate\ngateclient.exe"
Start-Process "C:\Program Files\OpenVPN Connect\OpenVPNConnect.exe"
Start-Process "$env:USERPROFILE\AppData\Roaming\Telegram Desktop\Telegram.exe"
Start-Process "C:\Users\Фёдор\AppData\Local\element-desktop\Element.exe"

# Запускаем отдельное окно хрома и в нем открываем необходимые вкладки
Start-Process $Chrome -Arg "--new-window", "https://mail.360.yandex.ru/?uid=1130000067773169#folder/38", "https://messenger.360.yandex.ru/#/chats/0%2F0%2F6b067f62-6df7-40d5-b511-4986c6daa1ca"
Start-Sleep 1.5
Start-Process $Chrome -Arg "--new-window", "http://confluence.im.loc/pages/viewpage.action?pageId=21338491", "https://mon.istelecom.msk.ru/d/S9lhRSjHz/istelecom-gw-2?orgId=1&refresh=30s&from=now-30m&to=now&timezone=Europe%2FMoscow"
Start-Sleep 1.5
Start-Process $Chrome -Arg "--new-window", "https://kgh.itsm.mos.ru/inbox?cv_id=14195&q=&vstate=assigned_to_my_team&vname=inbox&vlayout=table&order=-to_doable_created_at&column_keys=to_doable_created_at%2Cunread%2Cimpact_category%2Ctype%2Cpath%2Csubject%2Cstatus%2Cnext_target_at%2Cteam", "https://helpdesk.transport.mos.ru/sd/operator/#uuid:employee$39227806!{%22tab%22:%22b661b970-470d-404c-14f6-1144fae3f071,7b6f5ac2-3055-08c6-0ead-c672db076b3c%22}!encoded_prms=encoded_text$4025501", "https://grafana.evserver.intermb.ru/d/aes0ge5mqsflsb/support-overview?orgId=1&from=now-30m&to=now&timezone=Europe%2FMoscow&refresh=2m", "https://grafana.evserver.intermb.ru/d/nginx-vector-log-metrics/nginx-log-metrics?orgId=1&from=now-15m&to=now&timezone=Europe%2FMoscow&var-host=$__all&var-nginx_host=evaserver.ru&var-traffic=$__all&refresh=15s"

# Ждем 5 секунд пока вкладки прогрузятся
Start-Sleep 5

# Перемещение окон хром в нужное место
# Окно определяется по надписи на первой закладке в окне, например: "Яндекс Почта" или "Confluence", если названия другие, то можно ниже вписать свои
# Можно подправить расположение окна, пример: $leftX = X,  5 = Y, ($half + 10) = ширина окна,  $height = высота окна
Move-Window @("Яндекс Почта", "Яндекс") $leftX 5 ($half + 10) 500
Move-Window @("Confluence", "Отдел Мониторинга") ($leftX + $half) 5 $half $height
Move-Window @("Входящие", "Войти", "Helpdesk") ($rightX + 730) 5 ($half + 230) $height