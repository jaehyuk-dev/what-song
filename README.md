# 🎵 코노코노 (What Song) - 개인 노래방 음악 관리 앱

노래방에서 부를 노래를 체계적으로 관리하고 검색할 수 있는 개인 음악 관리 앱입니다.

## 📱 주요 기능

### 🏠 홈 화면
- **오늘의 추천곡**: 즐겨찾기한 노래 중 랜덤으로 추천곡 표시
- **검색 기능**: 추천곡을 TJ미디어 사이트에서 바로 검색
- **노래방 찾기**: 네이버 지도로 코인노래방 검색
- **최근 즐겨찾기**: 최근에 즐겨찾기한 노래 5곡 표시

### 🎼 노래 관리
- **카테고리별 분류**: K-POP, POP, 발라드, 힙합, 록, 인디, OST 등
- **즐겨찾기 기능**: 좋아하는 노래에 하트 표시
- **검색 연동**: 각 노래를 TJ미디어에서 바로 검색
- **스와이프 삭제**: 노래를 쉽게 삭제할 수 있는 직관적 UI

### 📁 카테고리 관리
- **기본 카테고리**: 장르별 기본 카테고리 제공
- **커스텀 카테고리**: 사용자 정의 카테고리 생성
- **카테고리 다중 선택**: 여러 카테고리를 한 번에 관리
- **확장/축소**: 카테고리별 노래 목록 토글

### 🔧 설정 및 기타
- **앱 스토어 평가**: 앱스토어 링크 연결
- **개발자 문의**: 이메일 연락 기능
- **개인정보처리방침**: 개인정보 보호 정책 링크
- **앱 초기화**: 모든 데이터 초기화 기능
- **버전 정보**: 현재 앱 버전 표시

## 🛠 기술 스택

### Frontend
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Dart**: 프로그래밍 언어
- **Material Design 3**: UI/UX 디자인 시스템

### 상태 관리
- **Provider**: 전역 상태 관리 (로딩 상태)
- **StatefulWidget**: 로컬 상태 관리

### 데이터베이스
- **SQLite**: 로컬 데이터 저장소
- **sqflite**: Flutter SQLite 플러그인

### 주요 라이브러리
- `url_launcher`: 외부 링크 및 앱 실행
- `shared_preferences`: 로컬 설정 저장
- `package_info_plus`: 앱 정보 조회
- `loading_indicator`: 커스텀 로딩 애니메이션
- `intl`: 날짜/시간 포맷팅

## 📋 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.5.4 이상
- Dart SDK
- Android Studio 또는 VS Code
- Android/iOS 개발 환경 설정

### 설치 과정

1. **저장소 클론**
```bash
git clone <repository-url>
cd what-song
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **스플래시 화면 생성**

```bash
dart run flutter_native_splash:create
```

4. **앱 실행**
```bash
# 디버그 모드
flutter run

# 릴리즈 모드
flutter run --release
```

### 빌드

**Android APK 빌드**
```bash
flutter build apk --release
```

**iOS 빌드**
```bash
flutter build ios --release
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── core/                        # 핵심 기능
│   ├── constant.dart           # 상수 정의
│   └── database_helper.dart    # SQLite 데이터베이스 관리
├── screen/                      # 화면 컴포넌트
│   ├── main_screen.dart        # 메인 네비게이션
│   ├── home_screen.dart        # 홈 화면
│   ├── song_list_screen.dart   # 노래 목록 관리
│   ├── search_store_screen.dart # 검색 상점 (준비중)
│   └── setting_screen.dart     # 설정 화면
├── service/                     # 서비스 계층
│   └── loading_service.dart    # 로딩 상태 관리
└── widget/                      # 재사용 가능한 위젯
    ├── custom_indicator.dart   # 커스텀 로딩 인디케이터
    └── main_layout.dart        # 메인 레이아웃
```

## 🗃 데이터베이스 스키마

### Categories 테이블
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
);
```

### Songs 테이블
```sql
CREATE TABLE songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  singer TEXT NOT NULL,
  is_favorite INTEGER DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
```

### 기본 카테고리
- K-POP
- POP  
- 발라드
- 힙합
- 록
- 인디
- OST

## 🎨 UI/UX 특징

### 디자인 테마
- **다크 테마**: 어두운 배경으로 눈의 피로감 최소화
- **포인트 컬러**: 오렌지(`#FF7A5A`) 계열 액센트 컬러
- **그라데이션**: 추천곡 카드에 핑크-블루 그라데이션 적용

### 사용자 경험
- **직관적 네비게이션**: 하단 탭 바 4개 메뉴
- **스와이프 제스처**: 노래 삭제를 위한 스와이프 기능
- **애니메이션**: 부드러운 확장/축소 애니메이션
- **반응형 디자인**: 다양한 화면 크기 대응

## 🔗 외부 연동

### TJ미디어 검색
- 노래 제목으로 TJ미디어 반주기 검색
- URL: `https://www.tjmedia.com/song/accompaniment_search`

### 네이버 지도
- 코인노래방 위치 검색
- 네이버 지도 앱 또는 웹에서 실행

## 🚀 향후 계획

### v1.1 (예정)
- [ ] 노래 번호 검색 UI 개선
- [ ] 노래방 검색 UI 개선
- [ ] 친구와 노래 목록 공유

### v1.2 (예정)  
- [ ] 노래 추천 알고리즘 개선
- [ ] 노래 번호 검색 알고리즘 고도화
- [ ] 실시간 인기 차트 연동

### v2.0 (장기)
- [ ] 소셜 기능 (친구 추가, 같이 부를 노래 추천)
- [ ] 백업/복원 기능


## 📞 문의 및 지원

- **개발자 이메일**: jaehyuk.dev@gmail.com
  - **GitHub Issues**: 버그 신고 및 기능 요청
- **개인정보처리방침**: [링크 준비중]

## 📄 라이선스

이 프로젝트는 개인 사용 목적으로 개발되었습니다.

## 🙏 감사의 말

노래방을 사랑하는 모든 분들을 위해 개발된 앱입니다. 
더 나은 노래방 경험을 위해 지속적으로 개선해 나가겠습니다.

---

**버전**: 1.0.0  
**최종 업데이트**: 2025년 06월 12일  
**개발자**: Jaehyuk