enum OtpValidityStatus { valid, invalid, expired }

OtpValidityStatus otpValidityStatusFromMap(String validityStatus) {
  if (validityStatus == "VALID") return OtpValidityStatus.valid;
  if (validityStatus == "INVALID") return OtpValidityStatus.invalid;

  return OtpValidityStatus.expired;
}
