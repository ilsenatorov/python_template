from setuptools import setup

with open("requirements.txt") as f:
    requirements = f.read().splitlines()


setup(
    name="python_template",
    version="0.1.0",
    author="Ilya Senatorov",
    author_email="il.senatorov@protonmail.com",
    packages=["python_template"],
    install_requires=requirements,
    python_requires=">=3.11",
)
