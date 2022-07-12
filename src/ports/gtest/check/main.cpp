
#include <gtest/gtest.h>

int Factorial(int n) {
  int result = 1;
  for (int i = 1; i <= n; i++) {
    result *= i;
  }
  return result;
}

TEST(Factorial, HandlesZeroInput) {
  EXPECT_EQ(Factorial(0), 1);
}

TEST(Factorial, HandlesPositiveInput) {
  EXPECT_EQ(Factorial(1), 1);
  EXPECT_EQ(Factorial(2), 2);
  EXPECT_EQ(Factorial(3), 6);
  EXPECT_EQ(Factorial(8), 40320);
}

#include <gmock/gmock.h>

class Example {
public:
  virtual bool Check() {
    return CheckImpl();
  }

private:
  virtual bool CheckImpl() {
    return true;
  }
};

class MockExample : public Example {
public:
  MOCK_METHOD(bool, CheckImpl, (), (override));
};

TEST(Example, Check) {
  using testing::Return;

  MockExample example;

  EXPECT_CALL(example, CheckImpl()).WillOnce(Return(true));
  EXPECT_TRUE(example.Check());

  EXPECT_CALL(example, CheckImpl()).WillOnce(Return(false));
  EXPECT_FALSE(example.Check());
}

int main(int argc, char* argv[]) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
