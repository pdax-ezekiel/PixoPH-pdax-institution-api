import csv
import uuid
import decimal
import math

class csvlib(object):

    """ Reads a given CSV file and returns it as a dictionary. """
    def read_csv_as_dictionary(self, filename, key_column, value_columns, delimiter=',', encoding = None):
        file = open(filename, 'r', encoding=encoding)
        csvfile = csv.DictReader(file, delimiter=delimiter)
        output = {}
        for row in csvfile:
            if type(value_columns) == str:
                output[row[key_column]] = row[value_columns]
            elif type(value_columns) == list:
                valueList = []
                for value in value_columns:
                    valueList.append(row[value])
                output[row[key_column]] = valueList

        file.close()
        return output
    
    def generate_uuid(self):
        
        uuid = str(uuid.uuid4())
        return uuid
        

    """ Reads a given CSV file and returns it as a list containing all rows as list. """
    def read_csv_as_list(self, filename, delimiter=',', encoding = None):
        file = open(filename, 'r', encoding=encoding)
        csvfile = csv.reader(file, delimiter=delimiter)
        output = []
        for row in csvfile:
            output.append(row)
        file.close()
        return output

    """ Reads a given CSV file and returns it as a single list containing all values. """
    def read_csv_as_single_list(self, filename, delimiter=',', encoding = None):
        file = open(filename, 'r', encoding=encoding)
        csvfile = csv.reader(file, delimiter=delimiter)
        output = []
        for row in csvfile:
            for value in row:
                output.append(value)
        file.close()
        return output
    
    def truncate_float(float_number, decimal_places):
        multiplier = 10 ** decimal_places
        return int(float_number * multiplier) / multiplier
    
    def count_decimal(self, number):
        """
        Returns the number of decimal places of
         """
        number_str = str(number)
        d = decimal.Decimal(number_str)
        n = abs(d.as_tuple().exponent)

        print(n)
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
