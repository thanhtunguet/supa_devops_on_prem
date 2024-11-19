part of login;

class _LoginController with AppLogger {
  _LoginController._(this.apiService);

  final AzureApiService apiService;

  final formFieldKey = GlobalKey<FormFieldState<dynamic>>();

  String pat = '';

  // ignore: use_setters_to_change_properties
  void setPat(String value) {
    pat = value;
  }

  Future<void> loginWithMicrosoft() async {
    final token = await MsalService().login();
    if (token == null) return;

    await _loginAndNavigate(token, isPat: false);
  }

  Future<void> login() async {
    final isValid = formFieldKey.currentState!.validate();
    if (!isValid) return;

    await _loginAndNavigate(pat, isPat: true);
  }

  Future<void> _loginAndNavigate(String token, {required bool isPat}) async {
    final isLogged = await apiService.login(token);

    final isFailed =
        [LoginStatus.failed, LoginStatus.unauthorized].contains(isLogged);

    logAnalytics(
      'signin_with_${isPat ? 'pat' : 'microsoft'}_${isFailed ? 'failed' : 'success'}',
      {},
    );

    if (isLogged == LoginStatus.failed) {
      _showLoginErrorAlert();
      return;
    }

    if (isLogged == LoginStatus.unauthorized) {
      final hasSetOrg = await _setOrgManually();
      if (!hasSetOrg) return;

      final isLoggedManually = await apiService.login(pat);
      if (isLoggedManually == LoginStatus.failed) {
        _showLoginErrorAlert();
        return;
      } else if (isLoggedManually == LoginStatus.unauthorized) {
        _showLoginErrorAlert();
        return;
      }
    }

    await AppRouter.goToChooseProjects();
  }

  void showInfo() {
    OverlayService.error(
      'Info',
      description:
          'Your PAT is stored on your device and is only used as an http header to communicate with Azure API, '
          "it's not stored anywhere else.\n\n"
          "Check that your PAT has 'User Profile' read enabled, otherwise it won't work.",
    );
  }

  void _showLoginErrorAlert() {
    OverlayService.error(
      'Login error',
      description: 'Check that your PAT is correct and retry',
    );
  }

  Future<bool> _setOrgManually() async {
    var hasSetOrg = false;

    String? manualOrg;
    await OverlayService.bottomsheet(
      title: 'Insert your organization',
      isScrollControlled: true,
      builder: (context) => Column(
        children: [
          DevOpsFormField(
            label: 'Organization',
            onChanged: (s) => manualOrg = s,
            onFieldSubmitted: () {
              hasSetOrg = true;
              AppRouter.pop();
            },
            maxLines: 1,
          ),
          const SizedBox(
            height: 40,
          ),
          LoadingButton(
            onPressed: () {
              hasSetOrg = true;
              AppRouter.pop();
            },
            text: 'Confirm',
          ),
        ],
      ),
    );

    if (!hasSetOrg) return false;
    if (manualOrg == null || manualOrg!.isEmpty) return false;

    await apiService.setOrganization(manualOrg!);

    return true;
  }

  void openSupavnWebsite(FollowLink? link) {
    logInfo('Open Supavn website');

    link?.call();
  }
}
