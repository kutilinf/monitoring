# 🖥️ Мониторинг: Автоматизация рабочего окружения

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![GitHub](https://img.shields.io/badge/GitHub-Repo-green)

---

## 📌 О проекте

Этот проект автоматизирует процесс подготовки рабочего окружения для сотрудников отдела мониторинга.  
Скрипт **одним нажатием** открывает все необходимые приложения и веб-интерфейсы, а затем размещает их на экранах в строго определённом порядке.

> ⚡ **Цель:** Сэкономить 5–7 минут каждый день и исключить рутину при начале смены.

---

## 🚀 Что делает скрипт?

- ✅ Закрывает старые окна Chrome
- ✅ Запускает:
    - Telegram
    - NGate (криптопровайдер)
    - OpenVPN Connect
    - Element (корпоративный мессенджер)
- ✅ Открывает рабочие веб-интерфейсы:
    - Яндекс Почта + Мессенджер
    - Confluence
    - Мониторинг ISTelecom
    - ITSM / Helpdesk
    - Grafana (Support Overview + Nginx Log Metrics)
- ✅ Автоматически **располагает окна** по мониторам:
    - Левый монитор: Почта (слева) + Confluence/Мониторинг (справа)
    - Правый монитор: Helpdesk/ITSM/Grafana

---

## 📁 Структура проекта

```
monitoring/
├── open-work.ps1          # Основной PowerShell-скрипт
├── .gitignore             # Исключения для Git
└── README.md              # Описание проекта
```

---

## 🛠️ Требования

| Компонент | Версия |
|-----------|--------|
| Windows 10/11 | — |
| PowerShell | 5.1+ |
| IntelliJ IDEA | 2024.3+ (опционально) |
| Google Chrome | Установлен |

---

## ⚙️ Настройка перед запуском

1. Убедитесь, что пути к приложениям в скрипте совпадают с вашей системой:

```powershell
$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
Start-Process "C:\Program Files\Crypto Pro\NGate\ngateclient.exe"
Start-Process "$env:USERPROFILE\AppData\Roaming\Telegram Desktop\Telegram.exe"
```

2. При необходимости измените высоту и ширину окон в конце скрипта:

```powershell
$WindowHeight1 = 500   # для Почты
$WindowHeight2 = 500   # для Confluence
$WindowHeight3 = 500   # для Helpdesk
```

---

## ▶️ Запуск

### 1️⃣ Через PowerShell (классический)

```powershell
powershell -ExecutionPolicy Bypass -File .\open-work.ps1
```

### 2️⃣ Через IntelliJ IDEA (External Tool)

- Настроен инструмент `Run Work Script`
- Запуск: `Tools → External Tools → Run Work Script`
- 🔥 Или по горячей клавише (если настроена)

### 3️⃣ Через `.bat` файл (для быстрого запуска)

Создайте `run.bat` рядом со скриптом:

```batch
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0open-work.ps1"
pause
```

---

## 🧠 Как это работает

Скрипт использует **WinAPI** для управления окнами:

- `EnumWindows` — находит все окна Chrome
- `SetWindowPos` / `MoveWindow` — перемещает и изменяет размер
- `ShowWindow` — восстанавливает свёрнутые окна
- Автоматическое определение мониторов через `System.Windows.Forms.Screen`

---

## 🖼️ Схема расположения окон

```
┌──────────────────────────────┬──────────────────────────────┐
│        Монитор 1 (левый)     │        Монитор 2 (правый)    │
│  ┌────────────┬────────────┐ │  ┌──────────────────────────┐│
│  │   Почта    │  Confluence │ │  │  Helpdesk + ITSM +       ││
│  │   +        │  +          │ │  │  Grafana (Support +      ││
│  │  Яндекс    │  Монитор    │ │  │  Nginx Log Metrics)      ││
│  │  Мессенджер│  ISTelecom  │ │  │                          ││
│  └────────────┴────────────┘ │  └──────────────────────────┘│
└──────────────────────────────┴──────────────────────────────┘
```

---

## 🐛 Если что-то пошло не так

| Проблема | Решение |
|----------|---------|
| Ошибка `ExecutionPolicy` | Добавьте `-ExecutionPolicy Bypass` |
| Окна не перемещаются | Проверьте заголовки окон в диагностике |
| Высота окна не меняется | Убедитесь, что окно не максимизировано |
| Приложение не найдено | Проверьте путь в скрипте |

---

## 📦 Версионность

Проект хранится в Git и GitHub:

```bash
git clone https://github.com/kutilinf/monitoring.git
cd monitoring
.\open-work.ps1
```

---

## 👤 Автор

**kutilinf**  
Инженер мониторинга 1 категории  
ООО "Интермобилити"

---

## 📄 Лицензия

MIT License — свободно используйте и дорабатывайте под свои нужды.

---

⭐ Если проект вам помог — поставьте звёздочку на GitHub!