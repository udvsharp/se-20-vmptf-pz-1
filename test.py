#! /usr/bin/python3

from module import Student

def print_students(students):
    for student in students:
        print("Surname:", student.surname)
        print("Initials:", student.initials)
        print("Group:", student.group)
        print("Grades:", student.grades)
        print("Scholarship:", student.scholarship)
        print()

def main():
    students = [
        Student("Smith", "J.", 1, [4.5, 5.0, 3.0], 500),
        Student("Johnson", "M.", 2, [5.0, 4.0, 5.0], 1000),
        Student("Johnson ADJ", "M.", 2, [5.0, 4.0, 2.0], 1000),
        Student("Williams", "A.", 1, [3.0, 3.5, 4.0], 750)
    ]

    print("Storing students:")
    print_students(students)
    print()

    Student.store_students(students, "students.bin")
    print("Students stored successfully!")

    students = Student.read_students("students.bin")

    print("Before the adjustment:")
    print_students(students)
    print()

    print("Adjusting scholarships...")
    students = Student.adjust_scholarships(students)

    Student.store_students(students, "students.bin")
    print("Students stored successfully!")

    students = Student.read_students("students.bin")
    print("After the adjustment:")
    print_students(students)
    print()


if __name__ == "__main__":
    main()