# mymap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


github token: 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


# [cjs] major version 업데이트는 안하는게 낫다 미지원으로 빌드가 안되는 경우가 많음
flutter pub upgrade
flutter pub upgrade --major-versions

---일반적으로는 여기만 하면 됨
#retrofit 모듈로 .g.dart 파일이 자동으로 생성이 되는데 변경사항이 있을때 새롭게 빌드를 할 필요가 있음.
flutter pub run build_runner build --delete-conflicting-outputs

매번 빌드해주면 귀찮으니 백그라운드로 실행되면서 바로 반영되도록
flutter pub run build_runner watch

# [kjh] Backend 서버 연결 설정
assets/config 폴더 내, config.yaml 수정
- apiBaseUrl:
  (appdu서버 연결 시) "https://backend-python-4haf34i.dev.appdu.kt.co.kr"
  (local서버 연결 시) "http://127.0.0.1:8000/"

# [kjh] 로컬에서 빌드 명령어 순서
1. flutter clean
2. flutter pub get
3. flutter pub run build_runner build --delete-conflicting-outputs
   1. flutter pub run build_runner build 

# [kjh] 사내PC에서, AVD 활용하여 앱 테스트 해보고 싶다면,
- 사내PC에서 가이드에 따라 기본적인 세팅이 완료되었다는 가정하에,
- AVD 실행 시, 애뮬레이터 정상동작
- 사내PC에서 바로 'run'하면 동작 안함 (이유: run/build 시 외부망을 참조하기 때문에 가이드를 따라서 보안조치 했다 해도 certification 오류남)
- APPDU > 빌드/배포 > Assemble 실행 후
- APPDU > 앱 다운로드 탭에서 APK 파일 다운로드 하여, 애뮬레이터에 드레그 앤 드롭하면 실행됨.


