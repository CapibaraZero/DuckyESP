# DuckyESP

DuckyESP is an interpreter of Duckyscript™ language, it can parse Hak5® Rubber Ducky™ payload and execute the same commands on ESP32-S2/S3. 

It fully supports Duckyscript 1.0 and almost all 3.0

Supported keywords, as per [Duckyscript docs](https://docs.hak5.org/hak5-usb-rubber-ducky/duckyscript-tm-quick-reference)

|         Keyword        |      Supported     |
| ---------------------- | ------------------ |
|     STRING/STRINGLN    | :white_check_mark: |
|           DELAY        | :white_check_mark: |
|      DEFAULT_DELAY     | :white_check_mark: |
|        Cursor keys     | :white_check_mark: |
|       Modifier keys    | :white_check_mark: |
|         Lock keys      | :white_check_mark: |
|       System keys      | :white_check_mark: |
|  Key modifier combo    | :white_check_mark: |
|           REM          | :white_check_mark: |
|        REM_BLOCK       | :white_check_mark: |
| WAIT_FOR_BUTTON_PRESS  | 	:warning:     |
|        BUTTON_DEF      |         :x:        |
|     DISABLE_BUTTON     | :white_check_mark: |
|      ENABLE_BUTTON     | :white_check_mark: |
| LED_G/LED_R/LED_OFF    | :white_check_mark: |
|        Attackmode      | :white_check_mark: |
|          DEFINE        | :white_check_mark: |
|           VAR          | :white_check_mark: |
|        Operators       |         :x:        |
| Conditional statements |         :x:        |
|          Loops         |         :x:        |
|         Functions      |         :x:        |
|      Randomization     | :white_check_mark: |
|         Jitter         | :white_check_mark: |
|   Wait for lock keys   |      :warning:     |

- Wait for lock keys can be parsed but implementation is not available yet.
- Wait for button press can be parsed but implementation is not available yet.
- The other keywords(also the one that there aren't in the table) will be available in future

## Layout

If you want to use a different layout from en_US you can put LAYOUT command at the begin of the script. More info [here]()

## Integrate with a project

Make sure that flex, bison and make are installed.

Then include the library using the git URL and follow the usage in example/ folder to use it.

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details.
