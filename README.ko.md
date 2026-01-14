# claude-code-notifier

[![License](https://img.shields.io/github/license/js-koo/claude-code-notifier)](LICENSE)
[![Version](https://img.shields.io/github/v/tag/js-koo/claude-code-notifier?label=version)](https://github.com/js-koo/claude-code-notifier/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)]()

[English](README.md) | [한국어](README.ko.md)

Claude Code 작업 완료 시 알림을 받아보세요 (Windows/macOS/Linux)

<details>
<summary>데모</summary>

![Demo](assets/demo.gif)

</details>

## 기능

- **크로스 플랫폼**: Windows (Native/WSL2), macOS, Linux 지원
- **스마트 알림**: 20초 이상 걸린 작업만 알림
- **프롬프트 미리보기**: 입력한 질문의 앞부분 표시
- **세션 인식**: 여러 Claude Code 세션을 독립적으로 관리
- **무설정**: 설치 즉시 사용 가능
- **슬래시 커맨드**: `/notifier` 명령어로 간편 설정

## 테스트된 환경

| 플랫폼 | 상태 |
|--------|------|
| macOS | ✅ 테스트 완료 |
| Linux | ✅ 테스트 완료 (Docker) |
| Windows (Native) | ⚠️ 미테스트 |
| Windows (WSL2) | ✅ 테스트 완료 |

> 문제를 발견하셨나요? [Issue를 열어주세요](https://github.com/js-koo/claude-code-notifier/issues)!

## 요구사항

- [Claude Code CLI](https://claude.ai/code)
- `jq` (JSON 처리기)
- **Linux 전용**: `libnotify-bin` (`notify-send` 사용)

## 설치

### Claude Code 플러그인으로 설치 (권장)

플러그인으로 Claude Code 실행:

```bash
claude --plugin-dir /path/to/claude-code-notifier
```

또는 프로젝트의 `.claude/settings.local.json`에 추가:

```json
{
  "plugins": ["/path/to/claude-code-notifier"]
}
```

### 독립 설치

#### 원라인 설치

```bash
git clone https://github.com/js-koo/claude-code-notifier.git && cd claude-code-notifier && ./install.sh
```

#### 수동 설치

1. 저장소 클론:
   ```bash
   git clone https://github.com/js-koo/claude-code-notifier.git
   cd claude-code-notifier
   ```

2. jq 설치 (없는 경우):
   ```bash
   # macOS
   brew install jq

   # Ubuntu/Debian
   sudo apt install jq

   # Fedora
   sudo dnf install jq
   ```

3. 설치 스크립트 실행:
   ```bash
   ./install.sh
   ```

4. Claude Code 재시작

## 삭제

```bash
~/.claude-code-notifier/uninstall.sh
```

또는 저장소가 있는 경우:

```bash
./uninstall.sh
```

## 설정

### 슬래시 커맨드 사용 (권장)

Claude Code에서 `/notifier` 명령어 사용:

| 명령어 | 설명 |
|--------|------|
| `/notifier help` | 사용 가능한 명령어 표시 |
| `/notifier status` | 현재 설정 표시 |
| `/notifier lang <en\|ko>` | 언어 설정 (en: English, ko: 한국어) |
| `/notifier duration <초>` | 최소 작업 시간 설정 (기본값: 20) |
| `/notifier preview <길이>` | 프롬프트 미리보기 길이 설정 (기본값: 45) |
| `/notifier test` | 테스트 알림 전송 |
| `/notifier uninstall` | claude-code-notifier 삭제 |

### 수동 설정

`~/.claude-code-notifier/hooks-handlers/config.sh` 편집:

```bash
# 언어 설정: "en" (English) 또는 "ko" (한국어)
NOTIFIER_LANG="ko"

# 알림을 표시할 최소 작업 시간 (초)
MIN_DURATION_SECONDS=20

# 프롬프트 미리보기 글자 수
PROMPT_PREVIEW_LENGTH=45
```

### 설정 옵션 설명

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `NOTIFIER_LANG` | `en` | UI 언어. `en`은 영어, `ko`는 한국어. 알림 메시지와 슬래시 커맨드 응답에 적용됩니다. |
| `MIN_DURATION_SECONDS` | `20` | 알림을 표시할 최소 작업 시간. 이 시간보다 빨리 완료된 작업은 알림이 표시되지 않습니다. `0`으로 설정하면 모든 작업에 알림이 표시됩니다. |
| `PROMPT_PREVIEW_LENGTH` | `45` | 알림에 표시할 원본 프롬프트의 글자 수. |

### 알림 메시지

메시지는 `NOTIFIER_LANG` 설정에 따라 자동으로 설정됩니다:

| 이벤트 | English | 한국어 |
|--------|---------|--------|
| 작업 완료 | Task completed! | 작업 완료! |
| 권한 필요 | Permission required! | 권한 필요! |
| 입력 대기 | Waiting for input... | 입력 대기 중... |

### 예시

**빠른 작업은 알림 제외:**
```bash
# 60초 이상 걸린 작업만 알림
/notifier duration 60
```

**항상 알림:**
```bash
# 모든 작업 완료 시 알림
/notifier duration 0
```

**긴 프롬프트 미리보기:**
```bash
# 원본 프롬프트를 더 많이 표시
/notifier preview 100
```

**영어로 전환:**
```bash
/notifier lang en
```

## 작동 방식

이 도구는 Claude Code의 [훅 시스템](https://docs.anthropic.com/en/docs/claude-code/hooks)을 사용합니다:

1. **UserPromptSubmit**: 작업 제출 시 프롬프트와 시작 시간 저장
2. **Stop**: Claude Code 완료 시 알림 표시 (설정 시간 초과 시)
3. **Notification**: 권한 요청 또는 입력 대기 시 알림
4. **SessionEnd**: 세션 종료 시 임시 파일 정리

세션 데이터는 `~/.claude-code-notifier/data/`에 저장됩니다.

## 문제 해결

### 알림이 표시되지 않음

**Windows (WSL)**:
- 설정 > 시스템 > 알림에서 Windows 알림이 활성화되어 있는지 확인
- 집중 지원 모드가 알림을 차단하고 있지 않은지 확인

**macOS**:
- 시스템 환경설정 > 알림에서 "Script Editor" 알림 허용

**Linux**:
- `libnotify-bin` 설치: `sudo apt install libnotify-bin`
- `notify-send` 작동 확인: `notify-send "테스트" "안녕하세요"`

### jq를 찾을 수 없음

패키지 관리자를 사용하여 jq 설치 (설치 섹션 참조)

### 훅이 등록되지 않음

1. `~/.claude/settings.json`에서 훅 항목 확인
2. 설치 스크립트 재실행: `./install.sh`
3. Claude Code 재시작

### WSL 경로 문제

기본이 아닌 WSL 배포판을 사용하는 경우에도 경로 변환이 자동으로 작동해야 합니다. 문제가 지속되면 `wslpath`가 사용 가능한지 확인하세요.

## 라이선스

MIT 라이선스 - [LICENSE](LICENSE) 파일 참조

## 기여

기여를 환영합니다!

- **버그 리포트 / 기능 제안**: [Issue 열기](https://github.com/js-koo/claude-code-notifier/issues)
- **코드 기여**: Pull Request 제출
- **새 언어 지원**: `README.<lang>.md` 추가 및 `config.sh` 업데이트
