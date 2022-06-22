import 'package:flutter/material.dart';
import 'package:tommy/generated/baseentity.pb.dart';

class Card extends StatefulWidget {
  final EntityAttribute attribute;
  const Card(this.attribute, {Key? key}) : super(key: key);
  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(widget.attribute.attributeName),
      
    ],);
  }
}

// const MotionBox = motion(Box)

// const DefaultCard = ({ parentCode, actions = [], code, columns }) => {
//   const realm = useGetRealm()
//   const title = useSelector(selectCode(code, getAttribute(columns[0] || '')), sameValue)
//   const subTitle = useSelector(selectCode(code, getAttribute(columns[1] || '')), sameValue)
//   const image = useSelector(
//     selectCode(code, realm === 'mentormatch' ? 'PRI_USER_PROFILE_PICTURE' : 'PRI_IMAGE_URL'),
//     sameValue,
//   )
//   const statusColor = useSelector(selectCode(code, 'PRI_STATUS_COLOR'), sameValue)
//   const color = useColorModeValue(`${statusColor?.value}.50`, `${statusColor?.value}.900`)

//   const userCode = useSelector(selectCode('USER'), equals)
//   const userType = getUserType(useSelector(selectCode(userCode), sameLength))

//   return (
//     <MotionBox w="full" whileHover={{ scale: 1.02 }} transition={{ duration: 0.1 }}>
//       <Card
//         // maxW={['80vw', '80vw', '22rem']}
//         p={[2, 2, 2, 4]}
//         variant="card1"
//         {...(statusColor?.value &&
//         statusColor?.value !== 'default' &&
//         !includes('#', statusColor?.value || '')
//           ? { bg: color }
//           : {})}
//       >
//         <Flex align="start">
//           <HStack align="start">
//             <Image.Read
//               config={{ size: 'lg' }}
//               data={image || { baseEntityCode: code }}
//               parentCode={parentCode}
//             />

//             <VStack alignItems="start" minW="10rem" maxW="16rem" overflow="hidden" spacing={1}>
//               <Text.Read
//                 data={title}
//                 config={{
//                   textStyle: 'body.1',
//                   isTruncated: true,
//                   maxW: '10rem',
//                 }}
//               />
//               <Text.Read
//                 config={{
//                   as: 'span',
//                   textStyle: 'body.3',
//                   maxW: '10rem',
//                 }}
//                 data={subTitle}
//               />
//               <MainDetails code={code} columns={columns} parentCode={parentCode} />
//             </VStack>
//           </HStack>

//           <Spacer minW="1rem" />
//           <ContextMenu
//             actions={actions}
//             code={code}
//             parentCode={parentCode}
//             button={
//               <Box align="start" border="1px" borderColor="gray.200" borderRadius="6px" px="2">
//                 <FontAwesomeIcon icon={faEllipsisV} size="xs" />
//               </Box>
//             }
//           />
//         </Flex>
//         {(userType === 'AGENT' || userType === 'ADMIN') && (
//           <AgentDetail code={code} parentCode={parentCode} />
//         )}
//         {userType === 'HOST_CPY_REP' && <HCRDetail code={code} parentCode={parentCode} />}
//       </Card>
//     </MotionBox>
//   )
// }

// export default DefaultCard
