set -e

# Section 1: blocktest (https://github.com/errata-ai/blocktest)
#
# These tests ensure that all of our code examples are up-to-date and
# functional.
ba="https://github.com/errata-ai/blocktest/releases/download/"

if [ "${OS}" == "Linux" ]
then
    bb="v${BLOCKTEST}/trust-v${BLOCKTEST}-x86_64-unknown-linux-gnu.tar.gz"
else
    bb="v${BLOCKTEST}/trust-v${BLOCKTEST}-x86_64-apple-darwin.tar.gz"
fi

bc=$ba$bb

errata_print 'TEST 1: Installing & running blocktest ...'
curl -sL $bc | tar xz && ./blocktest $2 .md $3

# Section 2: Vale (https://github.com/errata-ai/vale)
#
# These tests relate to our actual written content. We use Vale to check our
# spelling and, optionally, our adherence to an external style guide
# (see the `.vale.ini` file for more details).

# Install Vale using the version defined in `errata.sh`:
va="https://github.com/errata-ai/vale/releases/download/"
vb="v${VALE}/vale_${VALE}_${OS}_64-bit.tar.gz"
vc=$va$vb

errata_print 'TEST 2: Installing & running Vale ...'
curl -sL $vc | tar xz && ./vale --config='ci/content/.vale.ini' $3

