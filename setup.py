from setuptools import setup

setup(
    name='mkjson',
    py_modules=['mkjson'],
    entry_points={
        'console_scripts': [
            'mkjson = mkjson:main',
        ],
    }
)
