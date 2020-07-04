#!/usr/bin/python3

# apk add --no-cache py3-pip
# pip3 install mysql-connector-python

from mysql.connector import connect

def main():
  db_host = ''
  db_user = ''
  db_pass = ''
  db_name = ''

  with open("/etc/greyhole.conf") as config:
    for line in config:
      line = line.strip()
      if line.startswith('db_host'):
        db_host = line.split('=', 1)[1].strip()
      elif line.startswith('db_user'):
        db_user = line.split('=', 1)[1].strip()
      elif line.startswith('db_pass'):
        db_pass = line.split('=', 1)[1].strip()
      elif line.startswith('db_name'):
        db_name = line.split('=', 1)[1].strip()

  mydb = connect(
    host=db_host,
    user=db_user,
    password=db_pass,
    database=db_name
  )

  mycursor = mydb.cursor()

  mycursor.execute("SHOW TABLES")

  values = []
  for table in mycursor:
    values.append(table[0])

  for table in values:
    mycursor.execute(f'SELECT * FROM {table}')

    myresult = mycursor.fetchall()

    print(f'Checking Table: {table}')
    for row in myresult:
      print(row)
    print()

if __name__ == "__main__":
  main()
