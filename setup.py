from setuptools import setup

setup(
    name='mkjson',
    version="0.4.0",
    py_modules=['mkjson'],
    entry_points={
        'console_scripts': [
            'mkjson = mkjson:main',
        ],
    }
)
