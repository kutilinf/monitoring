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
    $callback = {
        param($hWnd, $lParam)
        if ([WinAPI]::IsWindowVisible($hWnd)) {
            $procId = 0
            [WinAPI]::GetWindowThreadProcessId($hWnd, [ref]$procId)
            try {
                $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
                if ($proc -and $proc.ProcessName -eq "chrome") {
                    $list.Add($hWnd) | Out-Null
                }
            } catch {
                # Игнорируем ошибки
            }
        }
        return $true
    }
    [WinAPI]::EnumWindows($callback, 0)
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
                #[WinAPI]::ShowWindow($h, $RESTORE)
                #[WinAPI]::SetForegroundWindow($h)
                #Start-Sleep -Milliseconds 300
                [WinAPI]::SetWindowPos($h, 0, $X, $Y, $W, 1035, $SWP)
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
Start-Process $Chrome -Arg "--new-window", "https://mail.360.yandex.ru/?uid=1130000067773169#folder/40", "https://messenger.360.yandex.ru/#/chats/0%2F0%2F6b067f62-6df7-40d5-b511-4986c6daa1ca"
Start-Sleep 2
Start-Process $Chrome -Arg "--new-window", "http://confluence.im.loc/pages/viewpage.action?pageId=21338491", "https://mon.istelecom.msk.ru/d/S9lhRSjHz/istelecom-gw-2?orgId=1&refresh=30s&from=now-15m&to=now&timezone=Europe%2FMoscow"
Start-Sleep 2
Start-Process $Chrome -Arg "--new-window", "https://kgh.itsm.mos.ru/login", "https://helpdesk.transport.mos.ru/sd/operator/", "https://grafana.evserver.intermb.ru/d/aes0ge5mqsflsb/support-overview?orgId=1&from=now-15m&to=now&timezone=Europe%2FMoscow&refresh=2m", "https://grafana.evserver.intermb.ru/d/nginx-vector-log-metrics/nginx-log-metrics?orgId=1&from=now-15m&to=now&timezone=Europe%2FMoscow&var-host=`$__all&var-nginx_host=evaserver.ru&var-traffic=`$__all&refresh=1m"

# Ждем 5 секунд пока вкладки прогрузятся
Start-Sleep 5

# Перемещение окон хром в нужное место
# Окно определяется по надписи на первой закладке в окне, например: "Яндекс Почта" или "Confluence", если названия другие, то можно ниже вписать свои
# Можно подправить расположение окна, пример: $leftX = X,  5 = Y, ($half + 10) = ширина окна,  $height = высота окна тут почемуто не работает, нужно жестко задать (например 1035) для всехокон, в строке выше  <<[WinAPI]::SetWindowPos($h, 0, $X, $Y, $W, 1035, $SWP)>>
Move-Window @("Яндекс Почта", "Яндекс") $leftX 5 ($half + 10) $height
Move-Window @("Confluence", "Отдел Мониторинга") ($leftX + $half) 5 $half $height
Move-Window @("Входящие", "Войти", "Helpdesk") ($rightX + 730) 5 ($half + 230) $height