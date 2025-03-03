import pytest

from tests.conftest import _clean_stdout


@pytest.mark.kinda_slow
def test_regex_rule__nosemgrep(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp(
            "rules/regex-nosemgrep.yaml", target_name="basic/regex-nosemgrep.txt"
        ).stdout,
        "results.json",
    )


@pytest.mark.kinda_slow
def test_nosem_rule(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(run_semgrep_in_tmp("rules/nosem.yaml").stdout, "results.json")


@pytest.mark.kinda_slow
def test_nosem_rule_unicode(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp(
            "rules/nosem-unicode.yaml", target_name="advanced_nosem/nosem-unicode.py"
        ).stdout,
        "results.json",
    )


@pytest.mark.kinda_slow
def test_nosem_rule__invalid_id(run_semgrep_in_tmp, snapshot):
    stdout, stderr = run_semgrep_in_tmp(
        "rules/nosem.yaml", target_name="nosem_invalid_id", assert_exit_code=2
    )

    snapshot.assert_match(stderr, "error.txt")
    snapshot.assert_match(_clean_stdout(stdout), "error.json")


@pytest.mark.kinda_slow
def test_nosem_rule__with_disable_nosem(run_semgrep_in_tmp, snapshot):
    snapshot.assert_match(
        run_semgrep_in_tmp("rules/nosem.yaml", options=["--disable-nosem"]).stdout,
        "results.json",
    )
