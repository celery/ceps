set -e

# Section 1: Front Matter
#
# The first structure test we run is for our front matter.
#
# We use the Node.js script `frontmatter.js` to define a JSON Schema that we then
# check our front matter against.
errata_print "TEST 3: Front Matter ..."

npm install --silent gray-matter # Extract the front matter.
npm install --silent glob        # Find the relevant files.
npm install --silent toml        # Used by `gray-matter`.
npm install --silent ajv         # Validate our schema.

node ci/structure/frontmatter.js $3 $FM_STYLE $FM_DELIM


# Section 2: Markup Style
#
# These tests relate to the structure (i.e., not the actual written content) of
# our markup (Markdown only, for now).
#
# See the `.markdownlint.json` file for more details.
#
# See https://github.com/igorshubovych/markdownlint-cli.
errata_print "TEST 4: Installing & running remark-lint ..."

npm install -g remark-cli &> /dev/null

# Install plugins:

# See https://github.com/cirosantilli/markdown-style-guide/
npm install -g remark-preset-lint-markdown-style-guide &> /dev/null
# Ensure external links are working
npm install -g remark-lint-no-dead-urls &> /dev/null

remark --quiet --rc-path="ci/structure/.remarkrc.json" $3

