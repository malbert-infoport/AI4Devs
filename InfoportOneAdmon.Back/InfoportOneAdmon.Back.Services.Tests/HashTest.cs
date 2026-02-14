using InfoportOneAdmon.Back.Data.Tests;
using Helix6.Base.Utils.Helpers;

namespace InfoportOneAdmon.Back.Services.Tests
{
    [Collection("Test Initialization")]
    public class HashTest
    {
        private readonly TestFixture _testFixture;

        private readonly string ORIGINAL = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
        private readonly string MD5 = "DB89BB5CEAB87F9C0FCC2AB36C189C2C";
        private readonly string SHA1 = "cd36b370758a259b34845084a6cc38473cb95e27";
        private readonly string SHA256 = "2d8c2f6d978ca21712b5f6de36c9d31fa8e96a4fa5d8ff8b0188dfb9e7c171bb";
        private readonly string SHA512 = "8ba760cac29cb2b2ce66858ead169174057aa1298ccd581514e6db6dee3285280ee6e3a54c9319071dc8165ff061d77783100d449c937ff1fb4cd1bb516a69b9";

        public HashTest(TestFixture testFixture)
        {
            _testFixture = testFixture;
        }

        [Fact]
        public void CheckMd5()
        {
            string calculatedHash = StringHelper.GenerateHash(ORIGINAL, StringHelper.HashTypes.MD5);
            Assert.Equal(MD5, calculatedHash);
        }

        [Fact]
        public void CheckSHA1()
        {
            string calculatedHash = StringHelper.GenerateHash(ORIGINAL, StringHelper.HashTypes.SHA1);
            Assert.Equal(SHA1, calculatedHash);
        }

        [Fact]
        public void CheckSHA256()
        {
            string calculatedHash = StringHelper.GenerateHash(ORIGINAL, StringHelper.HashTypes.SHA256);
            Assert.Equal(SHA256, calculatedHash);
        }

        [Fact]
        public void CheckSHA512()
        {
            string calculatedHash = StringHelper.GenerateHash(ORIGINAL, StringHelper.HashTypes.SHA512);
            Assert.Equal(SHA512, calculatedHash);
        }
    }
}