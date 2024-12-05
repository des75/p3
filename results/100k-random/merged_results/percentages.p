# output as png image
	set terminal png size 1024,768 crop

	# save file to benchmark.png
	set output "merged_percentages.png"

	# graph a title
	set title "Merged Test Results"

	# nicer aspect ratio for image size
	set size 1,0.7

	# y-axis grid
	set grid y

	# x-axis label
	set xlabel "Percentiles"

	# y-axis label
	set ylabel "Response time \(ms\)"

  set pointsize 1

	set datafile separator ","

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-42-49/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-42-49","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-43-50/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-43-50","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-44-58/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-44-58","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-46-09/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-46-09","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-05-23-47-18/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-05-23-47-18",
