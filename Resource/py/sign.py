import hashlib
import base64
from hmac import new
import math
import decimal
import PostgreSQLDB
import psycopg2


class sign(object):
    

    def get_digest(self, secret_key, webhook_method, webhook_endpoint, payload):
        message = webhook_method + webhook_endpoint + payload
        message = str.encode(message)
        return base64.b64encode(new(secret_key, message, digestmod=hashlib.sha256).digest())

    def get_digest_2(self, secret_key, payload, timestamp):
        message = timestamp + ":" + payload
        message = str.encode(message)
        return new(secret_key, msg=message, digestmod=hashlib.sha256).hexdigest()

    def digest(self, uuid):
        uuid = str(uuid)
        return hashlib.sha256(str.encode(uuid)).hexdigest()

    def count_decimal(self, number):
        """
        Returns the number of decimal places of
         """
        number_str = str(number)
        d = decimal.Decimal(number_str)
        n = abs(d.as_tuple().exponent)

        print(n)
        # number = float(number)
        #
        # if isinstance(number, str):
        #     number = float(number)
        #     print("Number is string")
        # print(number)
        # number_format = "{:f}".format(number)
        # number = str.rstrip(number, "0")
        # print(number)
        # print(len(str(number).split(".")))
        # if isinstance(number_format, int):
        #     n = 0
        #     print("Number is an integer")
        # elif len(str(number).split(".")) == 1:
        #     n = 0
        #     print("elif")
        # else:
        #     n = len(str(number).split(".")[1])
        #     print("Number has a decimal")
        return n

    def truncate(self, number, decimals=0):
        """
        Returns a value truncated to a specific number of decimal places.
        """
        print(decimals)
        print(number)
        if not isinstance(decimals, int):
            raise TypeError("decimal places must be an integer.")
        elif decimals < 0:
            raise ValueError("decimal places has to be 0 or more.")
        elif decimals == 0:
            return math.floor(number)

        factor = 10.0 ** decimals
        truncated = math.floor(number * factor) / factor
        print("******CHECKPOINT************")
        print(truncated)
        return truncated

    def is_in_dict(self, dictionary, key):
        """
        Returns true is the key is in the dictionary
        """
        if key in dictionary:
            return True
        else:
            return False

    def is_in_dict_value(self, test_dict, value):
        do_exist = False
        for key, val in test_dict.items():
            if val == value:
                do_exist = True
        return do_exist
