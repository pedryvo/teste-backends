require_relative "./solution.rb"

input_files = [
  "./../test/input/input000.txt",
  "./../test/input/input001.txt",
  "./../test/input/input002.txt",
  "./../test/input/input003.txt",
  "./../test/input/input004.txt",
  "./../test/input/input005.txt",
  "./../test/input/input006.txt",
  "./../test/input/input007.txt",
  "./../test/input/input008.txt",
  "./../test/input/input009.txt",
  "./../test/input/input010.txt",
  "./../test/input/input011.txt",
  "./../test/input/input012.txt"
]

output_files = [
  "./../test/output/output000.txt",
  "./../test/output/output001.txt",
  "./../test/output/output002.txt",
  "./../test/output/output003.txt",
  "./../test/output/output004.txt",
  "./../test/output/output005.txt",
  "./../test/output/output006.txt",
  "./../test/output/output007.txt",
  "./../test/output/output008.txt",
  "./../test/output/output009.txt",
  "./../test/output/output010.txt",
  "./../test/output/output011.txt",
  "./../test/output/output012.txt"
]

0..(input_files.size - 1).times do |index|
  input_lines = File.readlines(input_files[index])
  output_lines = File.readlines(output_files[index])

  input_lines.each(&:strip!)
  output_lines.each(&:strip!)

  if Solution.new.process_messages(input_lines) == output_lines.first
    puts "Test #{index + 1}/#{input_files.length - 1} - Passed"
  else
    puts "Test #{index + 1}/#{input_files.length - 1} - Failed"
  end
end
