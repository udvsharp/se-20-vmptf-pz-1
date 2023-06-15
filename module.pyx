import struct

class Student:
    def __init__(self, surname, initials, group, grades, scholarship):
        self.surname = surname
        self.initials = initials
        self.group = group
        self.grades = grades
        self.scholarship = scholarship

    @staticmethod
    def read_students(filename):
        students = []

        with open(filename, "rb") as file:
            num_students = struct.unpack("i", file.read(4))[0]

            for _ in range(num_students):
                surname_bytes = bytearray()
                while True:
                    byte = file.read(1)
                    if byte == b"\x00":
                        break
                    surname_bytes.append(byte[0])

                initials_bytes = bytearray()
                while True:
                    byte = file.read(1)
                    if byte == b"\x00":
                        break
                    initials_bytes.append(byte[0])

                surname = surname_bytes.decode("utf-8")
                initials = initials_bytes.decode("utf-8")

                group = struct.unpack("i", file.read(4))[0]

                grades = []
                for _ in range(3):
                    grade = struct.unpack("d", file.read(8))[0]
                    grades.append(grade)

                scholarship = struct.unpack("d", file.read(8))[0]

                student = Student(surname, initials, group, grades, scholarship)
                students.append(student)

        return students

    @staticmethod
    def store_students(students, filename):
        num_students = len(students)

        with open(filename, "wb") as file:
            file.write(struct.pack("i", num_students))

            for student in students:
                file.write(student.surname.encode("utf-8") + b"\x00")
                file.write(student.initials.encode("utf-8") + b"\x00")

                file.write(struct.pack("i", student.group))

                for grade in student.grades:
                    file.write(struct.pack("d", grade))

                file.write(struct.pack("d", student.scholarship))

    @staticmethod
    def adjust_scholarships(students):
        for student in students:
            if 2.0 in student.grades:
                student.scholarship *= 0.8

        return students