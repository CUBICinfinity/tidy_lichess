output=$(Rscript golden_tests/tests.R)

num=$(printf '%s\n' "$output" | grep -oE '[0-9]+$' | tail -n1)

if [ -z "$num" ]; then
	exit 255
elif [ "$num" -gt 255 ]; then
	num=255
fi

exit "$num"