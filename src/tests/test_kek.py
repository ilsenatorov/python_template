from ..kek import kek
from .fixtures import random_string


def test_kek(random_string):
    n = len(random_string)
    assert kek(random_string) == n
