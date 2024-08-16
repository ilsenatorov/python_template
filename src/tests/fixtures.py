import random
import string

import pytest


@pytest.fixture
def random_string():
    return "".join(random.choices(string.ascii_letters, k=10))
